---
name: artifact-eval-collab-review
description: Collaborative artifact-evaluation and review-writing workflow for research AEC processes. Use when a user wants help evaluating an artifact against reviewer guidelines, running kick-the-tires and full evaluation, preparing badge recommendations, and drafting or refining a final review in the user's writing style.
---

# Artifact Evaluation Collaboration Workflow

Read `references/reviewer-guidelines.md` at the start of every run. It is the source of truth for evaluation questions and review scope.

Read `references/review-synthesis.md` for distilled patterns from strong reviews.

Use `references/full-eval-execution-template.md` as the format guide when creating runbook files.

The runbook file is the persistent buffer between agent sessions. It tracks evaluation progress, user-filled results, and reviewer notes. It is not the author-facing review.

Use a cooperative, evidence-driven, conversational style. Ask one question at a time and expand only where evidence is missing.

## Inputs and setup

Require the artifact documentation (`artifact-doc`) before starting.

Ask for optional inputs when available:

- Paper intro/evaluation sections
- Source code (repository or archive)
- Prior user reviews for style matching

## Stage-gated process

Follow this order strictly. Ask user approval before advancing between stages.

1. **Kick-the-tires**: Read artifact doc, create runbook file with setup/sanity-check steps. User runs commands and fills in results.
2. **Full evaluation**: Extend the runbook with functionality and reusability sections. For reusability, the agent reads the source code and produces an evidence-based assessment autonomously. User runs experiment commands and fills in results/notes.
3. **Review drafting**: Agent reads the completed runbook and drafts the review. User and agent iterate to finalize.

## Runbook creation

Before any evaluation work, create a runbook file named `full-eval-<artifact>.md` in the working directory.

### Format rules

Use `references/full-eval-execution-template.md` as the structural guide. Key principles:

- **Group commands by claim** (RQ, figure, table, section), not one-per-card.
- **Bundle setup steps** (docker pull, env init, dependency install) into a single checklist per claim group.
- Each command group needs: claim it supports, commands to run, expected output, expected runtime, and blank fields for user results/notes.
- Keep it concise. No track labels, work-unit types, phase tags, or evidence IDs.
- Do not skip commands. Full evaluation means every documented command for validating paper claims.

### What goes in the runbook

- Context block (artifact name, paper, platform, date)
- Kick-the-tires checklist and results
- Functionality: command groups per claim with result fields
- Reusability: agent's code-review findings and user notes
- Reproducibility answers (synthesized from functionality evidence, not a separate execution stage)
- Badge worksheet
- Author questions (if blocked)

## Reusability evaluation

When source code is available, the agent must actively evaluate reusability rather than only asking the user. Read into the repository and assess:

- **Architecture**: directory structure, module boundaries, separation of concerns
- **Documentation quality**: README completeness, inline comments, API docs
- **Extension points**: how easy is it to add benchmarks, swap components, or modify parameters?
- **Dependency clarity**: are dependencies pinned? Is the build system well-defined?
- **License and availability**: open-source license present? Publicly hosted?

Sample key files (entry points, config, build files, representative modules) to form concrete observations. Include specific file paths and code snippets as evidence in the runbook's reusability section.

Do not treat code quality alone as sufficient for reproducibility. Reusability assessment supplements, not replaces, execution-based evidence.

## Execution assumptions

- Commands are always executed by the user (typically on a remote machine).
- The agent proposes commands and tracks them in the runbook; the user runs them and fills in results.
- When the user pastes results or notes into the runbook, the agent reads the updated runbook to continue.

## Badge and judgment policy

- Use reviewer-guideline criteria to assess Available, Functional, Reusable, and Results Reproduced.
- Propose badge recommendations with rationale, but always ask the user to confirm each badge decision.
- For result-comparison judgments, defer to user judgment if uncertainty remains.

## Drafting and refinement

Before producing the full review, ask permission explicitly. After drafting, refine with user feedback while preserving the user's writing style and final decision authority.

### Section order

Use this fixed order:

1. **Artifact summary** — what the artifact contains (source code, benchmarks, scripts, docker image, etc.)
2. **Kick-the-Tires Feedback** — concrete setup context: what was installed, what commands ran, what succeeded, what failed
3. **Reproducibility Concerns** (conditional) — include only when there are systemic risks early on (API dependency/cost, nondeterminism, missing cached outputs). Omit if no such risks exist.
4. **Full Review: Functionality** — start with a clear verdict sentence, then supporting evidence
5. **Full Review: Reusability** — start with a clear verdict sentence, then evidence and improvement suggestions
6. **Full Review: Result Reproduced** — per-claim reproduction status with evidence
7. **Badge Recommendation** (optional) — table of badge decisions with brief rationale

### Writing style

These are defaults. If the user provides prior reviews as writing samples, infer their style (tone, evidence density, phrasing patterns) and match it instead.

- Write in first-person reviewer voice: "I was able to...", "I could not reproduce...", "I ran..."
- Start each major review section with a verdict sentence before details (e.g., "The submission meets the criteria for the functional badge." or "The artifact is partially functional, but I cannot recommend the Functional badge at this stage.")
- For blockers, include raw command evidence inline: exact command + stderr/stdout snippets in code blocks.
- Quantify impact when possible (e.g., number of outputs generated before crash, percentage deviation from paper).
- Distinguish partial success from full reproduction explicitly; do not over-claim.
- Keep tone direct but collaborative: identify issues clearly, then propose actionable fixes.
- Use constructive framing for reusability gaps: "the documentation could be improved by..." rather than hard rejection language. Recommend specific improvements.
- Keep feedback concise. Avoid restating what the paper already says; focus on what the reviewer observed and how it differs.
