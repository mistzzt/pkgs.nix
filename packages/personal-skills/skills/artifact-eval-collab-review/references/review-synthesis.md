# Distilled Review Patterns

Concrete evaluation checklists distilled from strong reviews. Use alongside the reviewer guidelines.

## Evidence quality

For each claim in the review, attach at least one concrete evidence type:

- Command and output snippet
- Error trace or exception
- Figure/table/section mapping
- Resource/runtime observation
- Environment details (OS, architecture, tool versions)

Distinguish clearly between observed facts (what happened), interpretation (what it means), and recommendation (badge or action).

## Kick-the-tires

- Confirm whether baseline setup succeeds under documented instructions.
- Report blockers with reproducible steps and exact error output.
- Separate setup issues from artifact-design issues.
- Draft constructive author questions when blocked.
- Re-check previously blocked steps after author updates.

## Functionality

- Assess consistency between produced outputs and paper claims.
- Note which major workflows/scripts complete successfully.
- Report missing automation that increases reviewer burden.
- When only partial workflows are run, state scope limits explicitly.

## Reusability

- Evaluate code availability and license/public access separately from practical reusability.
- Look for extension guidance, package boundaries, and documented interfaces.
- Check whether docs explain how to adapt inputs/benchmarks.
- Acknowledge strengths while naming concrete improvements.

## Result reproduction

- Map each significant paper claim (figures/tables/RQs) to reproduction evidence.
- Accept reasonable numeric drift when trend-level claims remain consistent.
- Flag missing scripts for reproducing figures/tables as a reproducibility weakness.
- Call out unresolved mismatches precisely (which claim, what differs, how large).
- For comparative/baseline claims, avoid waiving evidence without explicit reviewer/user acceptance.
