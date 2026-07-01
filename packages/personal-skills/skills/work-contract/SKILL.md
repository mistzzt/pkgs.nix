---
name: work-contract
description: >-
  Plan-writing discipline for non-trivial work. A plan is incomplete until it
  carries two things, co-developed with the human: decision-boundary guardrails
  (when to proceed alone vs. stop and ask) and machine-checkable success
  criteria. Trigger when the user asks to plan, brainstorm, spec, or scope work,
  starts a larger project, or kicks off long-running autonomous work - including
  casual phrasings like "plan this" or "let's build X". Also trigger mid-task
  when the plan must change, or when you're an agent about to deviate from an
  agreed plan and unsure whether to proceed silently or ask.
---

# Work Contract

The reason a coding agent can't run unattended for long is rarely the code. It's the plan. Every non-trivial task hits something the plan didn't foresee: an API that doesn't exist, a constraint nobody mentioned, a cleaner design that wasn't on the table. At that moment the agent faces a judgment call it is bad at: _deviate silently, or stop and ask?_ Stop too often and you're useless. Deviate wrongly and you destroy trust (or data). And separately: without a crisp definition of "done," the agent either quits early or thrashes on changes nobody wanted.

So this is fundamentally about **how a plan gets written**. A plan that only says _what to build_ is half a plan. The half that lets an agent run unattended is the part that says _where the agent's authority ends_ and _how the agent knows it's done_ — and that half has to be built **with the human**, because only the human can authorize a boundary or accept a success bar. This skill is the discipline for writing that half into the plan, and for honoring it during execution.

It front-loads both decisions into an explicit, written **contract** — the governance core of the plan — so they don't have to be improvised under uncertainty mid-run.

The contract is only one piece of the agent harness. Its scope is deliberately narrow: make a plan executable by a future agent, not teach the whole repo or replace the surrounding tools. If the contract exposes missing repo knowledge, weak validation, repeated review feedback, or cleanup debt, record that and route it to the right durable home — docs, tests, scripts, charters, skills, or follow-up work — instead of bloating this one task.

Two artifacts, two granularities:

- **Charter** — standing guardrails + success bar for a _class_ of similar work (e.g. verification, synthesis, refactors, test-writing, infra changes). Reusable across many tasks. Lives in `.agent/charters/<class>.md`.
- **Contract** — one specific task. Inherits a charter, then adds task-specific scope, guardrails, and objective success criteria. Lives in `.agent/contracts/<task-slug>.md`.

For a small task, the contract is often just a short governance section appended to the plan itself — don't spawn a separate file when one paragraph of guardrails and three objective checks will do. For a larger project, it earns its own committed file and usually inherits a charter. Either way it is **committed to the repo** — reviewable in the PR that does the work, and surviving context compaction and session restarts, which is what makes long autonomous runs possible.

> First, adapt to the repo. If the project already has a convention for plans/specs (a `docs/` scratch area, an ADR directory, an issue template, a PR description), put the contract where a reviewer would expect it and match local naming. `.agent/` is only the default when there's no existing home. The contract is not bureaucracy bolted onto the plan — it _is_ the part of the plan that makes the plan executable unattended.

## What counts as success

This is the bar the skill is trying to hit, and the lens for every choice below. A plan written under this skill is good **if and only if** a competent executor — possibly a _future agent with none of this conversation's context_ — can run it to completion autonomously and:

- never crosses a hard boundary without having stopped to ask;
- never silently absorbs a scope/behavior change the human didn't agree to;
- knows objectively when it is done, and stops there — neither quitting early nor gold-plating.

A plan that requires the executor to _re-derive_ the boundaries or _guess_ the done-condition has failed, even if it reads well. Write the contract for that future executor, not for yourself today. The two pillars below are the load-bearing parts; everything else in the plan is scaffolding.

## Two phases — find your entry point

This skill has two distinct phases. They share one artifact (the contract) and one vocabulary (the taxonomy, hard/soft, objective checks), but you are almost always in exactly one of them. Identify which, and go straight there:

- **Phase A — Writing the plan.** The user asked you to plan, brainstorm, spec, or scope work, or you're about to start a larger project. You are _authoring_ the contract. → Go to **Phase A** below.
- **Phase B — Executing under the plan.** A contract already exists (you wrote it, or a previous agent did) and you are doing the work — including the moment mid-task when reality diverges from the plan and you must decide _proceed or ask_. You are _honoring_ the contract. → Skip to **Phase B** below.

If a contract exists but you're being asked to re-plan or substantially extend it, you're back in Phase A on that contract. The phases can hand off to each other, but keep them mentally separate: authoring asks "what could go wrong and how will we know we're done"; executing asks "given what's written, do I proceed."

---

# Phase A — Writing the plan

You are turning a request into a plan whose governance core a context-free future executor can run unattended. Work the six steps with the human; the output is the contract.

### A1. Locate or create the charter

Identify the class of work. Look in `.agent/charters/` for an existing one (`verification.md`, `refactor.md`, `infra.md`, …). If it fits, the contract inherits it — don't re-derive its rules. If no charter fits and this is a recurring class, propose a new charter to the human before generalizing one into existence; a charter is a standing commitment, so the human owns its creation.

### A2. Build the guardrails: specific → category → rule

Guardrails are the boundary between "proceed on your own" and "stop and ask." The failure mode to avoid is a brittle list of exact forbidden cases — that never generalizes, and the next task slips through a gap. The opposite failure is a vague "use good judgment," which gives the agent no real boundary.

The process, done _with the human_, is:

1. **Seed.** Start from the taxonomy in `references/escalation-taxonomy.md` — the categories of change that are usually escalation-worthy regardless of domain (scope, architecture, destructive/irreversible ops, security/secrets, external side-effects, dependency/version changes, user-visible behavior, deleting work).
2. **Make it specific to this task.** For each relevant category, write the concrete thing that could happen here. "Deviation: the planned `Foo.bar` API doesn't exist, so I'd need to add a public method to `Foo`." Specific is honest — it forces the real question into the open.
3. **Generalize with the human.** Ask: _what is the general category of behavior we want to forbid here, of which this is one instance?_ The goal is never to bless or ban this exact case — it's to kill the unhelpful/unsafe class it belongs to. The human's answer becomes the rule. Record both the rule and the originating example, so a future agent can judge edge cases by analogy instead of pattern-matching a literal.

A good guardrail reads like: _"Adding to a module's public API is a hard stop — propose it, don't ship it. (Origin: planned `Foo.bar` was missing; we want all surface-area expansion reviewed, not just this one.)"_

Classify every guardrail as **hard** (never proceed past it without approval — record it, batch it, ask) or **soft** (you may proceed if you record an explicit assumption in the contract and flag it prominently for review). When unsure whether something is hard or soft, treat it as hard. Hard is the safe default because an unwanted irreversible action costs far more than an interruption.

### A3. Make the inputs agent-legible

Before defining "done," make sure a future executor can find the inputs. The contract should name any repo-local context, command output, issue link, spec, artifact, or convention the agent needs. If the plan depends on private memory, chat history, undocumented taste, or "the usual way," either write the needed context into the contract or mark it as a planning blocker.

Examples:

- Bad: "Follow the usual development workflow." Better: "Inherit the workflow spec; focused component checks come before end-to-end acceptance runs."
- Bad: "Use the benchmark corpus as guidance." Better: "Oracle/debug artifacts may guide tests and diagnosis, but production code must derive results through the normal algorithmic path."
- Bad: "Fix whatever breaks after removing the shortcut." Better: "Record new reds against the baseline and write root causes; fixing those reds is a separate phase unless explicitly approved."

### A4. Define strictly objective success criteria

Every success criterion must be **machine-checkable**: a command that returns pass/fail, a test that goes green, a build that compiles, a project-wide check that passes, a specific reproduction that no longer reproduces. Write the exact check next to each criterion.

This is the agent's self-feedback signal. With it, the loop is "run the checks → not all pass → keep going → all pass → done." Without it, the agent guesses at "done" and either stops early or polishes forever.

**If a criterion cannot be made objective, that is itself an escalation at planning time.** Do not quietly accept a subjective criterion. Stop and ask the human to either (a) supply an objective proxy ("'reads cleanly' → no function over 40 lines + linter clean"), or (b) explicitly accept a named subjective criterion and say who judges it and when. An "objective" bar that silently degrades into vibes is worse than no bar, because it hides the gap.

Use the richest validation signal that is appropriate for the task, not just the nearest unit test. Good checks include:

- **Pipeline work:** focused checks for the changed stage before broad end-to-end acceptance runs.
- **Drift-sensitive optimizations:** a review checklist that distinguishes generic search bias from hardcoded answer injection, plus tests that exercise nearby unsupported cases.
- **Regression cleanup:** a baseline captured before the change, a post-change diff, and one root cause recorded for each new red.
- **Bug fixes:** the original reproduction no longer reproduces, plus the narrow regression test that covers it.
- **Generated artifacts:** regeneration/check commands plus a clean diff when generated output is expected.

### A5. Check autonomy readiness

Before asking for sign-off, do one pass from the future executor's point of view:

- Can it find the relevant files and conventions without this conversation?
- Can it reproduce or validate the starting state?
- Are all stop/ask boundaries explicit?
- Are all success checks runnable in the expected environment?
- Are deployment, network calls, secret edits, and other external effects explicitly in or out of scope?
- Is cleanup either in scope or captured as follow-up work?

For example, a task that changes a production pipeline using oracle/debug data should say whether that data is allowed only in tests or also in production. A task that removes a known shortcut should say whether newly failing end-to-end cases are acceptable output, blockers, or follow-up work.

### A6. Write the contract and get sign-off

Use the template in `references/templates.md`. The contract is short and is the thing the human approves before autonomous work begins. Approval of the contract _is_ the authorization — its scope is exactly what's written, no more.

Phase A is done when the contract is written and signed off. Hand to Phase B (often a different agent, or future-you with no memory of this conversation) — which is why the contract must stand on its own.

---

# Phase B — Executing under the plan

You have a contract (read it now if you haven't) and you're doing the work. Most of the time you just execute the plan. Phase B is the discipline for the two moments that decide whether an unattended run succeeds: when reality diverges from the plan, and when you think you're done.

> Entry point for a fresh executor: if you were handed a contract with no other context, your job is to execute its plan, run the **deviation protocol** at every divergence, and use the **self-evaluation loop** as your only definition of done. Do not re-derive the boundaries — they're written; do not invent a done-condition — it's written.

## Deviation protocol

When the plan no longer fits:

1. **Classify** the deviation against the contract's guardrails. Which category does it belong to? Hard or soft?
2. **Soft boundary** → you may proceed. Record the deviation and the assumption you're making in the contract's "Deviations" section, flagged for review. Keep going.
3. **Hard boundary** → **halt**. Stop touching code. Record the open decision in the contract. Then _batch_: scan ahead for other decisions likely blocked by the same uncertainty, so you ask once instead of five times. Present the human a tight summary: what you found, why it crosses the boundary, the options, your recommendation. Wait for the decision. Minimizing interruptions is a goal — but never by proceeding past a hard boundary.
4. **Genuinely novel** (no guardrail covers it) → treat as hard. After it's resolved, propose the generalized rule back into the charter so the next task is covered. The taxonomy is meant to grow this way.

A deviation is not a failure. Surfacing it correctly is the job. Silently absorbing a hard-boundary deviation is the only real failure here.

## Follow-up vs. blocker

Not every discovery should interrupt the task. Preserve autonomy by separating what must block this contract from what should be recorded for later:

- **Block now:** changing public interfaces, mutating shared infrastructure, editing secrets, deleting unfamiliar work, making irreversible changes, or changing the agreed user-visible behavior.
- **Record as follow-up:** nearby cleanup, better module factoring, docs polish, broader validation, missing reusable helpers, or a charter/tooling improvement that is useful but not needed for this task's success.
- **Proceed softly:** local formatting fixes in touched files, adding a narrowly-scoped regression test, or clarifying a name/comment when the contract already permits that class of edit.

If soft deviations accumulate enough to change the shape of the task, treat the aggregate drift as a hard boundary and ask.

## Self-evaluation loop

When you believe you're done — and periodically during long work — run every objective check in the contract. Report the actual command output, not a claim. If all pass and no hard-boundary deviation is unresolved, the task is complete: say so and stop (don't keep gold-plating). If any fail, continue. If a check itself turns out to be wrong or unrunnable, that's a contract defect — escalate it, don't silently rewrite the bar to something you can pass.

## Graduation loop

When the same kind of deviation, review comment, or missing context appears repeatedly, propose a durable home for the lesson instead of relying on future agents to rediscover it. The contract can record the discovery, but the long-term fix usually belongs elsewhere:

- Repeated "which layer owns this change?" → repo docs or an ownership decision table.
- Repeated "which check should run first?" → a validation ladder that orders focused diagnostics before broad acceptance checks.
- Repeated "is this optimization a shortcut?" → a drift policy or review checklist that names allowed bias and forbidden bypasses.
- Repeated "this benchmark went red after a cleanup" → a baseline/status register that separates expected regressions from new bugs.
- Repeated "agents forget to update evals for skills" → a skill-maintenance charter or skill.

Do not expand the current task silently to implement all of that. Either include it in the approved scope, ask if it should block, or record it as follow-up.

## Reference files

- `references/escalation-taxonomy.md` — the seed categories of escalation-worthy change, with the generalization questions to ask the human for each. Read this in Phase A, step A2.
- `references/templates.md` — the charter and contract templates. Read this in Phase A, steps A1 and A6.

## Anti-patterns

- **Contract theater.** Writing a contract, then ignoring it when inconvenient. The contract is only worth its weight if the deviation protocol is actually run at divergence points.
- **Over-specific guardrails.** Banning the exact case in front of you instead of the class it represents. The next task will be a sibling, not a twin.
- **Vibe criteria.** "Make it clean / robust / production-ready." Not checkable, so not a criterion. Objectify it or escalate it.
- **Escalation flooding.** Asking on every micro-decision because the guardrails were never sharpened into hard vs. soft. Fix the contract, don't drown the human.
- **Silent scope creep.** A string of individually-defensible soft deviations that together rebuild the task into something the human never agreed to. Re-read the contract's scope as a whole when soft deviations accumulate; aggregate drift is a hard boundary even when each step wasn't.
- **Hidden-context plans.** Writing "use the usual workflow" or "match house style" when the relevant workflow or style is not available to the future executor.
- **Harness hoarding.** Stuffing every repo convention, cleanup task, and validation policy into one contract instead of graduating repeated lessons into docs, checks, charters, or skills.
