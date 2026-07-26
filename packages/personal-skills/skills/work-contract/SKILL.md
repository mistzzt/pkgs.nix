---
name: work-contract
description: >-
  Plan-writing discipline for non-trivial work. A plan is complete only when it
  carries the two things a model cannot derive on its own: the few
  task-specific constraints this user actually cares about (elicited with
  targeted questions, not guessed and not padded) and machine-checkable
  success criteria. Trigger when the user asks to plan, brainstorm, spec, or
  scope work, starts a larger project, or kicks off long-running autonomous
  work, including casual phrasings like "plan this" or "let's build X". Also
  trigger mid-task when the plan must change.
---

# Work Contract

A capable agent with a decent plan still fails in two predictable ways, and both are information problems, not capability problems:

1. **It doesn't know which judgment calls this user cares about.** Default behavior is calibrated for a generic user. This user may be relaxed about an interface change a generic user would want reviewed, or picky about something defaults treat as free. Only the user can say which, and it varies per task.
2. **It doesn't know when it's done.** Without an objective bar, an executor stops early or polishes forever.

This skill closes exactly those two gaps. Everything else about safe execution (don't destroy work, don't leak secrets, confirm irreversible actions, don't silently expand scope) is already your default behavior; restating it in a plan wastes the reader's attention and buries the one constraint that matters.

## The delta rule

Write down only constraints that would change the behavior of a competent agent executing this plan. The test: would any well-run agent already do this on any task? Then it is noise; cut it. A good plan carries zero to three real constraints. If you find yourself writing more, you are padding, not planning.

## Elicit, don't guess

Draft the plan first. Then reread it hunting for the places where your judgment could plausibly diverge from the user's intent: spots where two reasonable approaches exist and the draft quietly picked one. Ask about only those, as concrete either/or questions that carry your recommendation:

- Bad: "Are there any constraints I should be aware of?"
- Good: "Storing idempotency keys needs a table. Add a new migration, or reuse the existing `request_log` table? I'd add a migration."

`references/divergence-checklist.md` lists the areas where user intent most often diverges from agent defaults. Use it privately to generate candidate questions; it is not a form to fill in and its categories must never appear as structure in the plan. Most tasks yield one to three questions. A task that yields zero is fine; ask nothing.

Skip any question whose answer would not change the plan. If the AskUserQuestion tool is available, use it; put your recommended option first.

## Write state, not history

A resolved decision does not get a labeled entry, a log line, or a "Decisions" section. It changes the plan text at the step it governs, as one plain sentence: "Add `triangle_area` as a new function; existing signatures stay untouched." Include the why only when the decision would surprise a reader, as a short parenthetical.

When a mid-execution decision changes the plan, rewrite the plan in place so it stays one coherent document. The history already lives, for free, in the conversation, the plan file's git history, and the PR. Duplicating it into the plan is what turns plans into tracking logs, and tracking logs are what make executors (and humans) stop reading plans.

## Definition of done

Every plan ends with success criteria, each paired with a runnable pass/fail check: a command, a test that goes green, a build that compiles, a reproduction that no longer reproduces. This is the executor's feedback loop: run the checks, not done until all green, stop when green.

If the request is subjective ("clean", "robust", "production-ready"), that is a planning-time escalation, not a bar to quietly self-define. Offer an objective proxy ("no function over 40 lines, linter clean") or ask the user to explicitly own the judgment call and say when they'll judge it. When you believe you are done, run the checks and report the actual output, not a claim.

## The fresh-executor test

Before calling the plan finished, reread it as an agent with none of this conversation's context: inputs named by path, no "the usual way" or "match house style" without a pointer to where that style lives, every check runnable in the expected environment. A plan that requires re-deriving the user's intent from vibes has failed, even if it reads well.

## Anti-patterns

- **Ceremony.** Hard/soft labels, origin annotations, deviation logs, guardrail sections, charter files. If a constraint cannot be phrased as a natural sentence of the plan, it is probably not a real constraint.
- **Restating defaults.** "Don't commit secrets", "don't force-push", "ask before deleting". Noise that buries the real constraint.
- **Question flooding.** Interrogating the user about every micro-decision. Ask only where the answer changes the plan; recommend an option every time.
- **Vibe criteria.** "Make it robust." Not checkable, so not a criterion. Objectify it or escalate it.
- **Tracking-log plans.** Append-only decision histories inside the plan. Rewrite in place; git remembers.
