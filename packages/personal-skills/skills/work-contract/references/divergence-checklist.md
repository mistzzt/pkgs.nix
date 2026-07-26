# Divergence checklist

Areas where user intent most often diverges from reasonable agent defaults. This is a private prompt for generating elicitation questions while rereading a draft plan. It is not a form: never fill it in, never mirror its categories as sections or labels in the plan, never ask about an area the task doesn't touch. Most tasks yield one to three questions total.

For each area, the question to ask yourself is: *did my draft quietly pick between two approaches a reasonable user could disagree on?* If yes, ask the user, concretely, with your recommendation.

## Scope elasticity

The draft probably includes or excludes adjacent work: cleanup riding along with a fix, a refactor the task invites but doesn't require, a nice-to-have dropped as out of scope. Users differ sharply on whether incidental improvement is welcome or noise.

## Interface and schema evolution

New public functions, widened signatures, schema or format changes. Some users treat surface area as frozen without review; others want the agent to evolve it freely. The draft picked one stance; check it.

## Where things land

New file vs. existing file, new table vs. reuse, new dependency vs. hand-rolled, new module vs. growing one. Placement choices look interchangeable to an agent and are often strongly opinionated for the user who maintains the code.

## Behavior visible to users or scripts

Defaults, flags, output formats, error messages and types. What existing consumers would notice. The classic silent trap: the plan "improves" something a downstream script parses.

## Budget

Compute, money, wall-clock, token spend. If a path in the plan could balloon well past what the request implied (a backfill, a big download, a long benchmark run), confirm the implied budget.

## Done-ness of the edges

What happens to newly-failing tests, discovered bugs, or half-related breakage: fix inline, record as follow-up, or treat as blocking? The draft assumed one; the user may want another.
