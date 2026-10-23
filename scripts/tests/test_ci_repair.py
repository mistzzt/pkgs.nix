import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import ci_repair as repair


def run_fixture():
    return {
        "name": "Update Packages", "path": ".github/workflows/update.yml",
        "conclusion": "failure", "event": "schedule", "head_branch": "main",
        "head_sha": "a" * 40, "head_repository": {"full_name": "owner/repo"},
        "html_url": "https://github.com/owner/repo/actions/runs/123", "id": 123,
        "run_attempt": 1,
    }


class SelectionTests(unittest.TestCase):
    def test_trusted_run_filters(self):
        run = run_fixture()
        self.assertTrue(repair.trusted_run(run, "owner/repo"))
        for changes in [
            {"head_branch": "repair/pkg"}, {"head_branch": "feature/foo"},
            {"head_repository": {"full_name": "fork/repo"}}, {"conclusion": "success"},
            {"event": "pull_request"}, {"path": ".github/workflows/other.yml"},
            {"head_sha": "$(bad)"}, {"name": "Unknown"},
        ]:
            with self.subTest(changes=changes):
                self.assertFalse(repair.trusted_run(run | changes, "owner/repo"))
        self.assertTrue(repair.trusted_run(run | {"event": "pull_request", "head_branch": "update/pkg"}, "owner/repo"))

    def test_extract_failed_matrix_packages(self):
        jobs = [{"name": name, "conclusion": state} for name, state in [
            ("build (pkg)", "failure"), ("update (pkg)", "failure"),
            ("update (other)", "success"), ("discover", "failure"),
            ("build (../../bad)", "failure"), ("build (cancelled)", "cancelled"),
        ]]
        self.assertEqual(repair.failed_packages(jobs), ["pkg"])

    @patch.dict(os.environ, {"GITHUB_REPOSITORY": "owner/repo"})
    @patch.object(repair, "api")
    def test_reject_stale_fork_and_repair_prs(self, api):
        run = run_fixture() | {"event": "pull_request", "head_branch": "update/pkg"}
        pr = {"state": "open", "head": {"ref": "update/pkg", "sha": "a" * 40,
              "repo": {"full_name": "owner/repo"}}, "base": {"ref": "main"}}
        api.return_value = [pr]
        self.assertTrue(repair.eligible(run))
        for field, value in [("sha", "b" * 40), ("repo", {"full_name": "fork/repo"}), ("ref", "repair/pkg")]:
            other = copy.deepcopy(pr)
            other["head"][field] = value
            api.return_value = [other]
            self.assertFalse(repair.eligible(run))
        api.return_value = [dict(pr, head={"ref": "repair/pkg"})]
        self.assertFalse(repair.eligible(run_fixture() | {
            "name": "Build Packages", "path": ".github/workflows/build.yml", "event": "push",
        }))
        self.assertTrue(repair.eligible(run_fixture()))

    def test_deduplication_key(self):
        self.assertEqual(repair.repair_branch("pkg", "main"), repair.repair_branch("pkg", "main"))
        self.assertNotEqual(repair.repair_branch("pkg", "main"), repair.repair_branch("pkg", "update/pkg"))

    def test_scope(self):
        for name in ["flake.lock", "packages/pkg.nix", "packages/pkg/default.nix", "packages/pkg/fix.patch"]:
            self.assertTrue(repair.allowed_path(name, "pkg"))
        for name in [".github/workflows/build.yml", "packages/other/default.nix", "packages/pkg/.gitattributes",
                     "packages/pkg/../../flake.nix", "packages/pkg/AGENTS.md", "/packages/pkg/a.nix"]:
            self.assertFalse(repair.allowed_path(name, "pkg"))


class PatchTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.previous = Path.cwd()
        os.chdir(self.temp.name)
        self.addCleanup(self.temp.cleanup)
        self.addCleanup(os.chdir, self.previous)
        Path("candidate/packages/pkg").mkdir(parents=True)
        Path("candidate/packages/pkg/default.nix").write_text("old\n")
        Path("candidate/packages/pkg/update.py").write_text("pass\n")
        Path("candidate/flake.lock").write_text("{}\n")
        self.git("init", "-q")
        self.git("config", "user.email", "test@example.com")
        self.git("config", "user.name", "Test")
        self.git("add", ".")
        self.git("commit", "-qm", "initial")
        Path("event.json").write_text(json.dumps({"workflow_run": run_fixture()}))
        self.env = patch.dict(os.environ, {
            "GITHUB_EVENT_PATH": "event.json", "GITHUB_REPOSITORY": "owner/repo",
            "GITHUB_OUTPUT": "outputs", "GITHUB_STEP_SUMMARY": "summary", "REPAIR_PACKAGE": "pkg",
        })
        self.env.start()
        self.addCleanup(self.env.stop)

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd="candidate", text=True)

    def proposed_patch(self, path="packages/pkg/default.nix", content="new\n"):
        file = Path("candidate") / path
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text(content)
        self.git("add", "-N", path)
        diff = self.git("diff", "HEAD")
        self.git("reset", "--hard", "-q")
        self.git("clean", "-fdq")
        return diff

    def result(self, diff):
        os.environ["REPAIR_RESULT"] = json.dumps({"patch": diff, "report": "Root cause and fix."})

    def test_valid_patch_preserves_exact_content(self):
        diff = self.proposed_patch()
        tree = repair.apply_patch(diff, "pkg")
        self.assertEqual(self.git("write-tree").strip(), tree)
        self.assertEqual(Path("candidate/packages/pkg/default.nix").read_text(), "new\n")

    def test_workflow_edit_is_rejected(self):
        with self.assertRaises(ValueError):
            repair.apply_patch(self.proposed_patch(".github/workflows/build.yml"), "pkg")

    def test_symlink_is_rejected(self):
        Path("candidate/packages/pkg/default.nix").unlink()
        Path("candidate/packages/pkg/default.nix").symlink_to("/etc/passwd")
        self.git("add", ".")
        diff = self.git("diff", "HEAD")
        self.git("reset", "--hard", "-q")
        with self.assertRaises(ValueError):
            repair.apply_patch(diff, "pkg")

    def test_oversized_patch_is_rejected(self):
        with self.assertRaises(ValueError):
            repair.apply_patch("x" * 48001, "pkg")

    @patch.object(repair, "run_check", return_value=True)
    def test_passed_checks_allow_ready_pr(self, check):
        self.result(self.proposed_patch())
        repair.verify()
        self.assertIn("verified=true", Path("outputs").read_text())
        self.assertEqual(check.call_count, 2)
        self.assertIn("Independent updater: passed", Path("repair-output/report.md").read_text())

    @patch.object(repair, "run_check", return_value=False)
    def test_failed_checks_produce_draft(self, check):
        self.result(self.proposed_patch())
        repair.verify()
        self.assertIn("changed=true\nverified=false", Path("outputs").read_text())
        self.assertIn("Publication: draft", Path("repair-output/report.md").read_text())

    def test_updater_mutation_prevents_ready_pr(self):
        proposed = self.proposed_patch()
        self.result(proposed)
        def mutate(args, log):
            if args[0] == "python3":
                Path("candidate/packages/pkg/default.nix").write_text("newer\n")
            return True
        with patch.object(repair, "run_check", side_effect=mutate):
            repair.verify()
        self.assertIn("verified=false", Path("outputs").read_text())
        self.assertEqual(Path("repair-output/repair.patch").read_text(), proposed)
        self.git("reset", "--hard", "-q")
        repair.apply()
        self.assertEqual(Path("candidate/packages/pkg/default.nix").read_text(), "new\n")

    def test_interrupted_verification_retains_diagnosis(self):
        self.result(self.proposed_patch())
        with patch.object(repair, "run_check", side_effect=KeyboardInterrupt):
            with self.assertRaises(KeyboardInterrupt):
                repair.verify()
        report = Path("repair-output/report.md").read_text()
        self.assertIn("Root cause and fix", report)
        self.assertIn("Verification has not finished", report)

    def test_untracked_updater_change_prevents_ready_pr(self):
        self.result(self.proposed_patch())
        def mutate(args, log):
            Path("candidate/packages/pkg/hashes.json").write_text("{}\n")
            return True
        with patch.object(repair, "run_check", side_effect=mutate):
            repair.verify()
        self.assertIn("verified=false", Path("outputs").read_text())

    @patch.object(repair, "run_check", return_value=True)
    def test_lock_change_builds_all_packages(self, check):
        self.result(self.proposed_patch("flake.lock", '{"updated": true}\n'))
        original = repair.command
        def fake_eval(*args, **kwargs):
            if args[:2] == ("nix", "eval"):
                return '["pkg", "other"]'
            return original(*args, **kwargs)
        with patch.object(repair, "command", side_effect=fake_eval):
            repair.verify()
        self.assertIn(".#other", check.call_args_list[0].args[0])

    def test_no_patch_and_missing_output_leave_diagnosis(self):
        for response in [json.dumps({"patch": "", "report": "Transient failure."}), "", "invalid"]:
            os.environ["REPAIR_RESULT"] = response
            repair.verify()
            self.assertEqual(Path("repair-output/repair.patch").read_text(), "")
            self.assertIn("No publishable patch", Path("repair-output/report.md").read_text())

    @patch.object(repair, "open_repairs", return_value=[{"number": 1}])
    @patch.object(repair, "command")
    def test_existing_pr_prevents_publication(self, command, existing):
        repair.publish()
        command.assert_not_called()

    @patch.object(repair, "open_repairs", return_value=[])
    @patch.object(repair, "command", return_value="")
    def test_publisher_drafts_unverified_patch_and_never_merges(self, command, existing):
        for verified in ["false", "true"]:
            command.reset_mock()
            os.environ["REPAIR_VERIFIED"] = verified
            repair.publish()
            calls = [call.args for call in command.call_args_list]
            create = next(args for args in calls if args[:3] == ("gh", "pr", "create"))
            self.assertEqual("--draft" in create, verified != "true")
            self.assertIn("main", create)
            self.assertFalse(any(args[:3] == ("gh", "pr", "merge") for args in calls))


if __name__ == "__main__":
    unittest.main()
