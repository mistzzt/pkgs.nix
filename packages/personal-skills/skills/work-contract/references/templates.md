# Templates

Keep both artifacts short. They are read under time pressure mid-task; length is a cost. Prose over ceremony — these formats are a guide, not a schema to satisfy.

## Charter — `.agent/charters/<class>.md`

Standing rules for a class of work. Written/changed only with human sign-off. A contract inherits one and overrides nothing silently.

```markdown
# Charter: <class of work, e.g. "verification tasks">

## Applies to

One or two lines: what kind of task inherits this.

## Standing guardrails

- [HARD] <rule>. (Origin: <the instance that motivated it>)
- [SOFT] <rule>. (Origin: <…>)
  ...

## Standing success bar

Objective checks every task in this class must pass, e.g.:

- `nix flake check` passes
- `<test command>` green
- <repro> no longer reproduces

## Notes

Anything a future agent needs to judge edge cases by analogy.
```

## Contract — `.agent/contracts/<task-slug>.md`

One task. This is the artifact the human approves before autonomous work starts. Approval scope = exactly what's written here.

```markdown
# Contract: <task in one line>

Inherits charter: <path or "none">

## Goal & non-goals

- Goal: <what success means, plainly>
- Non-goals: <explicitly out of scope — prevents silent scope creep>

## Plan

The intended approach, at the level of "what and why," not line-by-line code.

## Guardrails (task-specific, on top of the charter)

- [HARD] <rule>. (Origin: <instance>)
- [SOFT] <rule>. (Origin: <instance>)

## Success criteria (strictly objective)

Each criterion has an exact check. No check ⇒ escalate before starting.

- <criterion> → `<command / test / repro that proves it>`
- ...
  (If any criterion could not be objectified: note here who approved it as
  subjective, who judges it, and when.)

## Deviations (append-only log, filled during execution)

- <date/turn>: <what diverged> | <category> | hard/soft |
  <action taken or question asked> | <resolution>
```

## Filled contract example (abbreviated)

```markdown
# Contract: make `parse_config` reject unknown keys instead of ignoring them

Inherits charter: .agent/charters/refactor.md

## Goal & non-goals

- Goal: unknown keys in the config file raise a clear error.
- Non-goals: no change to known-key parsing; no new config keys.

## Plan

Add a strict pass after parsing that diffs seen keys against the schema and
raises `ConfigError` listing the offenders. Keep the existing parser intact.

## Guardrails

- [HARD] Changing the error type/format other code catches is a public-behavior
  change — propose, don't ship. (Origin: callers may `except ConfigError`.)
- [SOFT] Touching adjacent dead code is fine if it's strictly removal and
  noted. (Origin: noticed an unused branch near the parser.)

## Success criteria

- Unknown key raises ConfigError → `pytest tests/test_config.py -k unknown_key`
- No regression on valid configs → `pytest tests/test_config.py`
- Lint clean → `ruff check src/config.py`

## Deviations

- turn 4: planned `schema.keys()` is private (`_schema`) | architecture |
  hard | halted, asked: expose a public accessor or read `_schema` internally?
  | human: read internally, don't widen API. Recorded.
```
