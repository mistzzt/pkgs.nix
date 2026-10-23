# CI repair

`Repair CI Failures` watches failed `Update Packages` and `Build Packages` runs. It handles failures on `main` and open `update/*` PRs from this repository. Each failed package gets a separate repair attempt. Fork PRs, stale update commits, repair branches, and failures outside package jobs are skipped.

## Setup

Add `OPENAI_API_KEY` to the repository's Actions secrets. The key needs access to the Responses API and the selected model. API usage is billed to the key's project. Set a project budget in OpenAI and configure its available spending controls.

The workflow reuses `APP_ID` and `APP_PRIVATE_KEY` from the package updater. The GitHub App needs Contents and Pull requests write permissions. Its token creates repair branches and PRs so normal PR CI runs.

Optionally set the repository variable `CODEX_REPAIR_MODEL` to a model available to your API project. An empty variable uses the Codex CLI default. The Codex Action is pinned to a commit, while its CLI uses the latest published release. Merge the workflow into `main` to enable the `workflow_run` trigger. It responds to future workflow completions, including reruns of failed runs.

## Execution and review

The investigation job gives Codex the failed logs, commit, and package diff. Codex works on the workflow's pinned `main` commit. It can incorporate the failing update into its proposal. Its output contains a patch and a diagnosis. Codex runs last in that job with sudo removed. It has network and filesystem access for Nix, but no GitHub write token or GitHub App secret. Nix does not grant the runner trusted-user privileges.

A fresh job applies the patch and builds the package. A lockfile change requires builds of all packages exposed for `x86_64-linux`. For updater failures, the job also runs the updater and makes sure that it leaves the proposed files unchanged. A separate publication job applies the same patch before obtaining the App token. It never executes code from the patch.

Repair PRs target `main` from `repair/*` branches and require human review. The workflow never enables auto-merge. Passing verification produces a ready PR. Failed verification produces a draft PR. Invalid or empty patches produce no PR. The job summary and the `repair-<package>` artifact retain the diagnosis and available logs for 14 days. An interrupted agent with no output gets a report that points to its job logs.

An open repair PR blocks new attempts for the same package and source branch. Review, merge, or close that PR before another attempt. Closing a PR permits a new attempt on a later failure. The updater's `update/*` branch is never modified. After a repair merges, the next updater run can refresh the original update PR.

The workflow allows two packages to start in parallel per failed run. Investigation and verification each have a 40-minute timeout. Each verification command has a 25-minute timeout. Patches are limited to 48,000 characters and reports to 8,000 characters. These limits bound each attempt, not total daily API spending.

## Scope and local checks

Repairs can change `flake.lock`, `packages/<package>.nix`, and `.nix`, `.json`, `.py`, or `.patch` files under `packages/<package>/`. The publisher rejects symlinks, submodules, hidden paths, and edits outside this scope. Failures that need workflow or shared updater changes require a manual repair. Independent verification covers Linux only. Normal PR CI remains the merge gate.

Run the helper tests with `python3 -m unittest discover -s scripts/tests -v`. Run workflow validation with `nix run nixpkgs#actionlint -- .github/workflows/repair.yml .github/workflows/repair-package.yml .github/workflows/repair-checks.yml`. The tests use local Git repositories and mocked GitHub and Nix calls. They do not call the model or create PRs.

See the [Codex GitHub Action documentation](https://learn.chatgpt.com/docs/github-action) for the runner and API configuration.
