#!/usr/bin/env python3
"""Select CI failures, validate proposed patches, and publish reviewable repairs."""

import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys

PACKAGE = re.compile(r"[a-zA-Z0-9][a-zA-Z0-9_-]*")
WORKFLOWS = {
    "Update Packages": ".github/workflows/update.yml",
    "Build Packages": ".github/workflows/build.yml",
}
OUTPUT = Path("repair-output")
CANDIDATE = Path("candidate")


def command(*args, cwd=None, **kwargs):
    return subprocess.check_output(args, cwd=cwd, text=True, **kwargs).strip()


def api(endpoint, *args):
    return json.loads(command("gh", "api", endpoint, *args))


def repository():
    return os.environ["GITHUB_REPOSITORY"]


def event_run():
    return json.loads(Path(os.environ["GITHUB_EVENT_PATH"]).read_text())["workflow_run"]


def output(name, value):
    with open(os.environ["GITHUB_OUTPUT"], "a") as stream:
        stream.write(f"{name}={value}\n")


def summary(message):
    with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as stream:
        stream.write(message + "\n")


def trusted_run(run, repo):
    branch = run.get("head_branch", "")
    return (
        run.get("conclusion") == "failure"
        and run.get("head_repository", {}).get("full_name") == repo
        and WORKFLOWS.get(run.get("name")) == run.get("path")
        and re.fullmatch(r"[0-9a-f]{40}", run.get("head_sha", "")) is not None
        and (
            branch == "main" and run.get("event") in {"push", "schedule", "workflow_dispatch"}
            or re.fullmatch(r"update/[a-zA-Z0-9][a-zA-Z0-9_-]*", branch) is not None
            and run.get("event") == "pull_request"
        )
    )


def failed_packages(jobs):
    packages = set()
    for job in jobs:
        match = re.fullmatch(r"(?:update|build) \(([a-zA-Z0-9][a-zA-Z0-9_-]*)\)", job["name"])
        if job["conclusion"] == "failure" and match:
            packages.add(match[1])
    return sorted(packages)


def repair_branch(package, branch):
    digest = hashlib.sha256(branch.encode()).hexdigest()[:12]
    return f"repair/{package}-{digest}"


def open_repairs(branch):
    return api(f"repos/{repository()}/pulls", "--method", "GET", "-f", "state=open",
               "-f", f"head={repository().split('/')[0]}:{branch}")


def eligible(run):
    if not trusted_run(run, repository()):
        return False
    prs = api(f"repos/{repository()}/commits/{run['head_sha']}/pulls")
    if run["name"] == "Build Packages" and any(pr["head"]["ref"].startswith("repair/") for pr in prs):
        return False
    if run["event"] == "pull_request":
        return any(
            pr["state"] == "open" and pr["head"]["ref"] == run["head_branch"]
            and pr["head"]["sha"] == run["head_sha"]
            and (pr["head"]["repo"] or {}).get("full_name") == repository()
            and pr["base"]["ref"] == "main"
            for pr in prs
        )
    return True


def discover():
    run = event_run()
    packages = []
    if eligible(run):
        pages = api(f"repos/{repository()}/actions/runs/{run['id']}/attempts/{run['run_attempt']}/jobs?per_page=100",
                    "--paginate", "--slurp")
        packages = failed_packages([job for page in pages for job in page["jobs"]])
    output("packages", json.dumps(packages))
    if not packages:
        summary("No eligible package failures. Forks, repair branches, stale update PRs, and non-package jobs are skipped.")


def package_name():
    name = os.environ["REPAIR_PACKAGE"]
    if not PACKAGE.fullmatch(name):
        raise ValueError("Invalid package name")
    return name


def prepare():
    run, package = event_run(), package_name()
    branch = repair_branch(package, run["head_branch"])
    if not eligible(run) or open_repairs(branch):
        output("started", "false")
        summary(f"Skipped {package}: ineligible run or an open repair PR already exists.")
        return
    if os.environ["OPENAI_KEY_PRESENT"] != "true":
        raise ValueError("Set the OPENAI_API_KEY repository secret to enable CI repair")
    evidence = Path("evidence")
    evidence.mkdir()
    context = {
        "package": package, "workflow": run["name"], "failed_sha": run["head_sha"],
        "source_branch": run["head_branch"], "failed_run": run["html_url"],
        "base_sha": command("git", "rev-parse", "HEAD", cwd=CANDIDATE),
    }
    (evidence / "context.json").write_text(json.dumps(context, indent=2))
    logs = command("gh", "run", "view", str(run["id"]), "--attempt", str(run["run_attempt"]),
                   "--repo", repository(), "--log-failed")
    (evidence / "failure.log").write_text(logs)
    command("git", "fetch", "origin", run["head_sha"], cwd=CANDIDATE)
    diff = command("git", "diff", f"HEAD...{run['head_sha']}", "--",
                   f"packages/{package}", f"packages/{package}.nix", "flake.lock", cwd=CANDIDATE)
    (evidence / "source.diff").write_text(diff + "\n")
    output("started", "true")


def allowed_path(path, package):
    parts = PurePosixPath(path).parts
    if not parts or any(part.startswith(".") for part in parts) or "\\" in path:
        return False
    return path == "flake.lock" or path == f"packages/{package}.nix" or (
        len(parts) > 2 and parts[:2] == ("packages", package)
        and PurePosixPath(path).suffix in {".nix", ".json", ".py", ".patch"}
    )


def apply_patch(patch, package, cwd=CANDIDATE):
    if not patch or len(patch) > 48000 or "GIT binary patch" in patch:
        raise ValueError("Missing, oversized, or binary patch")
    subprocess.run(["git", "apply", "--index", "--whitespace=error", "-"], cwd=cwd,
                   input=patch, text=True, check=True)
    paths = command("git", "diff", "--cached", "--name-only", "--no-renames", "-z", cwd=cwd).split("\0")
    if not paths or any(not allowed_path(path, package) for path in paths if path):
        raise ValueError("Patch changes files outside the permitted package scope")
    modes = command("git", "diff", "--cached", "--raw", "--no-renames", cwd=cwd)
    for line in modes.splitlines():
        old_mode, new_mode = line.split()[:2]
        if old_mode[1:] not in {"000000", "100644", "100755"} or new_mode not in {"000000", "100644", "100755"}:
            raise ValueError("Patch changes a symlink or submodule")
    command("git", "diff", "--cached", "--check", cwd=cwd)
    return command("git", "write-tree", cwd=cwd)


def run_check(args, log):
    with log.open("w") as stream:
        try:
            result = subprocess.run(args, cwd=CANDIDATE, stdout=stream, stderr=subprocess.STDOUT,
                                    timeout=1500, check=False)
            return result.returncode == 0
        except subprocess.TimeoutExpired:
            stream.write("\nVerification timed out after 25 minutes.\n")
            return False


def verify():
    run, package = event_run(), package_name()
    OUTPUT.mkdir(exist_ok=True)
    report = f"Failed run: {run['html_url']}\n\nFailed commit: `{run['head_sha']}`\n"
    (OUTPUT / "report.md").write_text(report + "\nVerification has not finished. Inspect the job logs if it was interrupted.\n")
    changed, verified, patch = False, False, ""
    try:
        result = json.loads(os.environ.get("REPAIR_RESULT") or "{}")
        patch, diagnosis = result.get("patch", ""), result.get("report", "")
        if not isinstance(patch, str) or not isinstance(diagnosis, str) or len(diagnosis) > 8000:
            raise ValueError("Invalid agent response")
        report += "\n" + (diagnosis or "The agent did not return a diagnosis. Inspect the investigation job logs.") + "\n"
        (OUTPUT / "report.md").write_text(report + "\nVerification has not finished.\n")
        if patch:
            tree = apply_patch(patch, package)
            changed = True
            targets = [package]
            paths = command("git", "diff", "--cached", "--name-only", cwd=CANDIDATE).splitlines()
            if "flake.lock" in paths:
                targets = json.loads(command("nix", "eval", "--json", "--apply", "builtins.attrNames",
                                             ".#packages.x86_64-linux", cwd=CANDIDATE))
            verified = run_check(["nix", "build", "--no-link", "-L", *[f".#{p}" for p in targets]], OUTPUT / "build.log")
            report += f"\nIndependent build ({', '.join(targets)}): {'passed' if verified else 'failed'}.\n"
            if run["name"] == "Update Packages":
                updater_ok = run_check(["python3", f"packages/{package}/update.py"], OUTPUT / "update.log")
                verified = verified and updater_ok
                report += f"\nIndependent updater: {'passed' if updater_ok else 'failed'}.\n"
            unchanged = subprocess.run(["git", "diff", "--quiet"], cwd=CANDIDATE).returncode == 0
            unchanged = unchanged and command("git", "write-tree", cwd=CANDIDATE) == tree
            unchanged = unchanged and not command("git", "ls-files", "--others", "--exclude-standard", cwd=CANDIDATE)
            verified = verified and unchanged
            if not unchanged:
                report += "\nVerification changed the proposed files; the proposed patch has not been fully verified.\n"
    except (ValueError, subprocess.CalledProcessError) as error:
        verified = False
        report += f"\nRepair could not be verified: {error}\n"
    if not changed:
        patch = ""
        report += "\nNo publishable patch was produced.\n"
    report += f"\nPublication: {'ready for review' if verified else 'draft' if changed else 'no PR'}.\n"
    (OUTPUT / "repair.patch").write_text(patch)
    (OUTPUT / "report.md").write_text(report)
    summary(report)
    output("changed", str(changed).lower())
    output("verified", str(verified).lower())


def apply():
    apply_patch((OUTPUT / "repair.patch").read_text(), package_name())


def publish():
    run, package = event_run(), package_name()
    branch = repair_branch(package, run["head_branch"])
    if open_repairs(branch):
        summary("An open repair PR already exists; leaving it unchanged.")
        return
    command("git", "checkout", "-b", branch, cwd=CANDIDATE)
    command("git", "-c", "core.hooksPath=/dev/null", "-c", "user.name=github-actions[bot]",
            "-c", "user.email=41898282+github-actions[bot]@users.noreply.github.com",
            "commit", "-m", f"{package}: repair CI failure", cwd=CANDIDATE)
    command("gh", "auth", "setup-git", cwd=CANDIDATE)
    refs = command("git", "ls-remote", "origin", f"refs/heads/{branch}", cwd=CANDIDATE)
    previous = refs.split()[0] if refs else ""
    command("git", "push", f"--force-with-lease=refs/heads/{branch}:{previous}",
            "origin", f"HEAD:refs/heads/{branch}", cwd=CANDIDATE)
    args = ["gh", "pr", "create", "--repo", repository(), "--base", "main", "--head", branch,
            "--title", f"{package}: repair CI failure", "--body-file", str(OUTPUT / "report.md")]
    if os.environ["REPAIR_VERIFIED"] != "true":
        args.append("--draft")
    summary(command(*args))


if __name__ == "__main__":
    {"discover": discover, "prepare": prepare, "verify": verify, "apply": apply, "publish": publish}[sys.argv[1]]()
