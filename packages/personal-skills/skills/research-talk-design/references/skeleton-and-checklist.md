# Slide Skeleton and Diagnostic Checklist

## Reusable slide skeleton (20-25 min)

Adapt the counts to the time slot (about one slide per minute). This is a starting
scaffold, not a mandate; reorder when the paper's argument calls for it.

1. Title + one-sentence problem (formal title; short tool/brand name introduced later).
2. World / context: why the setting matters.
3. Background vocabulary ladder: one primitive per slide, in dependency order; the
   last rung is a concrete, quantified real-world failure (the motivation).
4. Problem statement: one diagram + one correctness contract; if outcomes are dual,
   show both.
5. Challenge: annotate the formal goal or before/after code to expose where the
   difficulty lives.
6. Method map: the recurring "you are here" diagram.
7. Key idea 1: intuition -> object -> example -> payoff.
8. Key idea 2: same beats; if two engines are combined, draw the division of labor once.
9. One representative hard derivation (not all details).
10. Recap of contributions.
11. Benchmarks -> baselines -> ablations (each paying off an earlier claim).
12. Limitations, if useful.
13. Summary slide: Problem / Method / Results + the pipeline + a call to action
    (repo, QR, artifact). Never a bare "Thanks!".

## Diagnostic checklist

Use this to pressure-test an outline or an existing draft. A "no" is a place to work.

**Purpose and structure**
- Is the goal clear (audience reads or remembers the paper), and does every slide serve it?
- Does the talk follow the paper's argument rather than a from-scratch rewrite?
- Can the one-sentence takeaway be stated in a sentence?
- Does the macro-structure mirror the real guarantees, including negative/partial outcomes?
- Are section titles phrased as the audience's questions, each answering the prior one?

**Content moves**
- Is there an anchor example (or two, for dual outcomes) in every major technical section?
- Does the background introduce each needed primitive on its own slide, in dependency order?
- Is the motivation a concrete, quantified failure that the results later pay off?
- Does every design choice answer a specific obstacle and get removed in an ablation?
- Is the challenge derived by annotating the formal goal, not a disconnected list?
- Is there one recurring method map, reused at preview, transitions, and summary?
- Does each technical section follow intuition -> object -> example -> takeaway?
- Is formalism rationed to contract + reframing + soundness bridge, with one representative rule?
- If two engines are mixed, is their division of labor one picture with a stated principle?
- Are dense ideas progressively disclosed, including by re-annotating a figure later?
- Does the evaluation answer usefulness / performance / necessity, each paying off a claim?
- Is there a foundational "instead of X we do Y" reframing?

**Slide craft and delivery**
- Is each key point made in more than one modality (spoken + shown + read)?
- Does each slide title carry its main point, with no bullet-only slides?
- Was the talk outlined top-down before slides were built, and budgeted at ~1 slide/min?
- Does the final slide summarize (not a bare "Thanks!") and stay useful during Q&A?
- Is the speaker rehearsed to time and genuinely enthusiastic?

## Common failure modes and fixes

- **"It feels like a list of components."** Apply obstacle-driven motivation
  (pattern 7): reorder so each component answers a problem the audience just saw.
- **"People get lost in the middle."** Add or reuse the method map at transitions
  (pattern 9) and add a recap at the altitude change (pattern 11).
- **"Too much notation."** Ration formalism (pattern 10); move proofs/rules to an
  expert-only aside or the paper.
- **"The opening falls flat."** Replace an abstract motivation with a concrete,
  quantified failure (pattern 6).
- **"It's over time."** Use the purpose test (pattern 1) to cut anything that does
  not move a non-expert toward reading the paper.
- **"The results don't feel connected."** Reorder evaluation to answer the planted
  questions and make each slide pay off an earlier claim (pattern 13).
