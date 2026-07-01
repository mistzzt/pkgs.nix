# Escalation Taxonomy (seed)

These are the categories of change that are _usually_ escalation-worthy regardless of domain. They are a starting point, not a finished policy. For each relevant category: write the concrete instance for the current task, then ask the human the generalization question to turn it into a charter/contract rule. Record the rule **and** the originating instance.

The point is never to bless or ban one exact case. It's to name the general class of unsafe/unhelpful behavior the case belongs to, so future tasks are covered by analogy.

## 1. Scope

Doing more (or less) than the agreed task. New features, refactors riding along with a fix, "while I was in here" cleanup, or silently dropping agreed work as "not needed."

Generalization question: _What expansions or contractions of scope are pre-authorized vs. need a check-in? Is incidental cleanup welcome or unwanted noise here?_

## 2. Architecture & interfaces

Changing a public API, a data schema, a module boundary, a wire/serialization format, or a cross-component contract. Cheap to type, expensive to reverse, affects callers you can't see.

Generalization question: _Which surfaces are frozen without review? Which are the agent's to evolve freely?_

## 3. Destructive or irreversible operations

Deleting files/branches/data, dropping tables, force-push, history rewrite, `rm -rf`, killing processes, overwriting uncommitted work, irreversible migrations.

Generalization question: _Which of these are categorically off-limits without explicit per-instance approval, regardless of how confident the agent is?_ (Default: all of them are hard.)

## 4. Security, secrets, permissions

Anything touching credentials, auth, access control, encryption, secret storage, or that would put a secret somewhere world-readable. In this repo specifically: never hardcode secrets into Nix (they land world-readable in `/nix/store`) — that's a hard boundary by construction.

Generalization question: _What is the standing rule for the security-relevant class this falls into, so we forbid the category rather than this one leak?_

## 5. External / shared side-effects

Actions visible outside the local workspace: pushing, opening/closing/commenting on PRs or issues, sending messages (Slack/email), posting to external services, deploying, mutating shared infra, uploading content to third-party tools.

Generalization question: _Which outward-facing actions are pre-authorized for this work, and which always need a human in the loop?_

## 6. Dependencies & versions

Adding/removing/upgrading/downgrading dependencies, bumping language/runtime versions, changing lockfiles, swapping a library for another.

Generalization question: _Is dependency change in-scope for this task at all? If yes, what's the bar (security only? minor only? any?) before it needs review?_

## 7. User-visible behavior

Changing defaults, CLI flags, output format, error messages, UX, or anything an existing user/script would notice. Backward-incompatible behavior change is the classic silent-deviation trap.

Generalization question: _What behavior is contractually stable for users here, and what is the agent free to change?_

## 8. Deleting or discarding work

Resolving a conflict by discarding a side, blowing away a stash, reverting someone's commit, removing a lockfile, deleting unfamiliar files/branches that may be in-progress work.

Generalization question: _What's the rule when the agent encounters unexpected existing state — investigate-and-ask, or proceed?_ (Default: investigate before destroying; unfamiliar state is presumed to be someone's work.)

## 9. Cost / resource / time blowup

A path that balloons compute, money, build time, or token spend far past the implied budget (full retrain, massive backfill, combinatorial search, huge data download).

Generalization question: _What's the implicit budget for this task, and at what multiple of it must the agent stop and confirm?_

## Using this list

Most tasks engage only 2–4 of these. Don't mechanically fill all nine — that produces contract theater. Pick the categories that this task can realistically collide with, make them concrete, generalize them with the human, and classify each resulting rule **hard** (halt/batch/ask) or **soft** (proceed with a recorded, flagged assumption). When in doubt: hard.
