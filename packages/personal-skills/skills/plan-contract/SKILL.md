---
name: plan-contract
description: >-
  Plan-writing discipline for non-trivial work. Trigger when the user asks to
  plan, brainstorm, spec, or scope work, starts a larger project, or kicks off
  long-running autonomous work ("plan this", "let's build X"), and mid-task
  when the plan must change.
---

# Plan Contract

A plan is complete when it carries exactly two things an executor cannot derive on its own: the few task-specific constraints this user actually cares about, and a machine-checkable definition of done. Everything else buries them.

## The delta rule

Write down only constraints that would change the behavior of a competent agent executing this plan. The test: would any well-run agent already do this on any task? Then it is noise; cut it. "Don't commit secrets", "ask before deleting", hard/soft labels, guardrail sections, deviation logs, charter files: all noise. If a constraint cannot be phrased as a natural sentence of the plan, it is probably not a real constraint. A good plan carries zero to three real constraints; more means you are padding.

## Elicit, don't guess

Draft the plan first. Then reread it hunting for spots where two reasonable approaches exist and the draft quietly picked one, including choices made by omission; those are where your judgment could diverge from the user's intent. Ask about only those, as concrete either/or questions that carry your recommendation:

- Bad: "Are there any constraints I should be aware of?"
- Good: "Storing idempotency keys needs a table. Add a new migration, or reuse the existing `request_log` table? I'd add a migration."

Most tasks yield one to three questions; zero is fine. Skip any question whose answer would not change the plan. If the AskUserQuestion tool is available, use it; put your recommended option first.

## Write state, not history

A resolved decision changes the plan text at the step it governs, as one plain sentence: "Add `triangle_area` as a new function; existing signatures stay untouched." Include the why only when the decision would surprise a reader, as a short parenthetical. A rejected alternative gets one sentence at most, and only when a fresh executor would plausibly wander into it; otherwise omit it entirely.

When a mid-execution decision changes the plan, rewrite the plan in place so it stays one coherent document. The history already lives in the conversation, the plan file's git history, and the PR; duplicating it into the plan turns plans into tracking logs, and tracking logs are what make executors stop reading plans.

## Review to convergence

Before calling a non-trivial plan finished, have a fresh-context subagent review it, and iterate until a round produces no objection that changes the plan. Brief the reviewer on the bar: the fresh-executor test below and the delta rule. If no subagent tool is available, run the fresh-executor test yourself instead. Do not ask whether the plan is "thorough"; that question rewards length.

Resolve each objection by changing the plan or by rejecting it, never by adding defensive text. A justification paragraph written to satisfy a reviewer is bloat by construction: it is addressed to the reviewer, not the executor. Each review round should leave the plan the same size or smaller unless review uncovered genuinely missing scope; a plan that grows across rounds without gaining new work is accumulating scar tissue, not quality.

## Definition of done

Every plan ends with success criteria, each paired with a runnable pass/fail check: a command, a test that goes green, a build that compiles, a reproduction that no longer reproduces. This is the executor's feedback loop: run the checks, not done until all green, stop when green.

If the request is subjective ("clean", "robust", "production-ready"), that is a planning-time escalation, not a bar to quietly self-define. Offer an objective proxy ("no function over 40 lines, linter clean") or ask the user to explicitly own the judgment call. When you believe you are done, run the checks and report the actual output, not a claim.

## The fresh-executor test

Before calling the plan finished, reread it as an agent with none of this conversation's context: inputs named by path, no "the usual way" or "match house style" without a pointer to where that style lives, every check runnable in the expected environment. A plan that requires re-deriving the user's intent from vibes has failed, even if it reads well.
