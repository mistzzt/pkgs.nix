# Talk Design Pattern Catalog

Reusable patterns for turning a paper into a talk story. Each pattern states the
move, why it works, and a worked example from one of two well-received talks:

- **Opera**: synthesizing an online (streaming) algorithm from its offline (batch)
  version. Always produces an answer.
- **Ink**: deciding whether a user-defined aggregation is a homomorphism, then
  synthesizing its merge operator or proving none exists. Dual outcome.

Use the examples as illustrations of the move, not as content to copy. The moves
apply to systems, PL, ML, theory, and most method talks.

## Contents

1. Purpose and audience
2. Reuse the paper's spine
3. Anchor example
4. Question-chain macro-structure
5. Mirror the guarantees (including negative outcomes)
6. Vocabulary ladder + quantified-failure motivation
7. Obstacle-driven design choices, cashed out as ablations
8. Derive the challenge by annotating the formal goal
9. One recurring method map
10. Intuition -> object -> example -> takeaway, and rationed formalism
11. Progressive disclosure and recaps
12. Search-vs-reasoning (two-engine) division of labor
13. Results answer the planted questions
14. Foundational reframing
15. Slide craft
16. Outline-first process
17. Delivery
18. Sources

---

## 1. Purpose and audience

Decide this before anything else. A conference talk's goal is not to convey every
technical result; it is to get the key ideas and contributions across to an
audience that is mostly non-expert, so they go read the paper or remember it
later. Peyton Jones' target: give an intuitive feel for the idea and make them
"foam at the mouth" to read the paper.

Two consequences: (a) success is a citation or a memory, not coverage, which
licenses aggressive cutting; (b) detail that does not move a non-expert toward the
paper is a cutting candidate. Write the single sentence you want an attendee to
repeat a week later, and make everything serve it.

## 2. Reuse the paper's spine

The paper already motivated the problem, argued no good solution existed, and
explained why the approach works, and its introduction did this for a general
audience. Reuse that argument, order, examples, and illustrations. Do not rewrite
from scratch. "Reconstruction rather than compression" means you cut to the
essence and add visual/example scaffolding for a live room, not that you invent a
new argument. Both Opera and Ink track their papers' introductions closely.

## 3. Anchor example, not just an example

Use one example as the *structure* of the talk, not decoration. A good anchor fits
on one slide, contains the main difficulty, has a clear before/after, is revisited
in every technical section, and makes the payoff visible without the full theorem.

- Opera opens with `variance` two ways: a naive two-pass offline program and
  Welford's online algorithm. That pair exposes the real challenge (extra
  auxiliary state, a nonlinear recurrence) and recurs in every technical section.
- Ink uses **two** anchors with different jobs: a *negative* one (a clickstream
  aggregation where a field snapshots another, so no merge can exist) to motivate
  the refutation half, and a *positive* one (an auction-bids aggregation with a
  map-valued field) to carry synthesis and to be the thing that makes naive
  synthesis explode.

Rule: if the contribution has two kinds of outcome, use one anchor per outcome.
Thread the anchor through background, problem, challenge, key idea, one algorithm
step, and evaluation.

## 4. Question-chain macro-structure

Order sections so each answers a question the previous one planted, and title
sections as those questions. Opera: "why online algorithms?", "what is the
challenge?", "how does opera work?". Ink: "does merge always exist?", "what is the
challenge?", "how well does it work?".

Skeleton: Why care (world + pain) -> What is the problem (formal goal) -> Why hard
(challenge) -> Key idea (reframing) -> How it works (method) -> Does it work
(evidence) -> Takeaway.

## 5. Mirror the guarantees, including negative outcomes

Let the macro-structure reflect what the method actually guarantees. Opera always
produces output, so its problem statement is a single arrow. Ink's answer can be
"no", so it makes this a dual-outcome contribution: Synthesize (a correct merge)
vs. Refute (prove none exists), with the reframing "either way the developer gets a
trustworthy answer". Refutation is not a caveat; it gets a pipeline stage, a
results number, and its own ablation.

Related move: if a verification result can be read as a synthesis specification
(or vice versa), show the flip explicitly. Ink turns "a UDAF is a homomorphism iff
its accumulator has a normalizer, and that normalizer is the merge" into the task
"find a normalizer", collapsing decision and construction into one problem.

## 6. Vocabulary ladder + quantified-failure motivation

Build the background as a ladder: list the primitives the key idea needs that an
outsider would not know, and introduce each on its own slide in dependency order,
so the formal statement lands on already-defined vocabulary. Calibrate the ladder's
length to how exotic the primitives are; familiar ones get one slide.

- Ink climbs frameworks + aggregations -> init/accumulate (the fold model) -> the
  merge operator (and why it enables parallel/incremental execution) -> the formal
  correctness condition -> what goes wrong when merge is wrong. Every symbol in the
  definition is defined before it appears.

End the background on the motivating pain, and make it concrete and quantified: Ink
opens with "found bugs in 9 of 45 sampled real aggregations", and the results later
pay this off ("finds real bugs in hand-written merges"). A measured "before" that
pays off as a measured "after" beats an abstract motivation and doubles as evidence
that the benchmarks are realistic.

## 7. Obstacle-driven design choices, cashed out as ablations

Never present the method as a list of components. Introduce each because the
audience just saw a problem that requires it, then remove it later in the
evaluation to prove it mattered.

Template: *naively we might try ___, but that fails because ___, so we introduce
___, which works because ___, and on the running example it gives ___.*

- Opera: unknown online state -> infer a relational spec; hard equivalence ->
  reframe as inductiveness; too-hard whole-program synthesis -> decompose into
  independent holes; big-expression search -> add symbolic reasoning. The ablation
  removes decomposition and symbolic reasoning.
- Ink: intractable whole-dataframe correctness -> reduce to a per-row property;
  non-terminating search for a nonexistent merge -> refutation rules; SyGuS
  explosion on rich state -> type-directed decomposition. The ablation removes each.

Each "therefore we introduce ___" should eventually be a bar on a chart.

## 8. Derive the challenge by annotating the formal goal

Rather than a disconnected bullet list of challenges, write the formal goal (or
before/after code) once and highlight the specific fragments that make it hard,
with short callouts, so the audience locates the difficulty inside a statement they
already accepted.

- Ink annotates the homomorphism definition: the universal quantifier ("over all
  dataframes"), the concatenation operator ("arbitrary dataframes"), the
  aggregation applied to a piece ("unbounded").
- Opera puts offline `variance` beside Welford with callouts "additional states
  needed" and "complex non-linear expressions", and even pastes the header of the
  real Welford (1962) paper, a quiet authority-citation signaling the target is a
  famously hard, published algorithm.

## 9. One recurring method map

Make one diagram of the whole pipeline and reuse it: to preview the method, to mark
transitions, and as the closing summary. Repetition lowers cognitive load and
covers transitions, which is where talks lose people.

- Ink's map (UDAF -> Refute? -> Decompose -> SyGuS -> Combine -> merge) reappears
  verbatim on the summary poster.
- Opera's map reuses its skeleton on the poster but relabels and expands one box
  for detail. Verbatim reuse is strongest; skeleton-plus-expansion also works if the
  audience recognizes the shape.

## 10. Intuition -> object -> example -> takeaway, and rationed formalism

Give each technical subsection four beats: intuition (what to believe before
notation), object (the definition/diagram/equation), example (its behavior on the
anchor), takeaway (what it bought). No abstraction should travel more than one
slide without an example beside it.

- Ink stages its central abstraction across dedicated slides: intuition ("reduce
  verification to a local per-row property"), object (a commuting diagram), pivot
  ("find a normalizer of the accumulator").

Ration formalism to exactly three kinds of content, and defer the rest to the
paper:

- **Contract**: what correctness means (an equivalence, a definition).
- **Key reframing**: what makes the method possible (the central invariant/idea).
- **Soundness bridge**: why satisfying the new condition solves the original problem
  (the theorem or iff).

Be ruthless about the rest: reference proofs, type rules, and equations for
interested readers rather than presenting them. Keep a small number of deliberately
expert-only asides, flagged so the general audience knows not to worry, to seed
post-talk conversations; both talks do this with a single representative rule or
theorem slide.

## 11. Progressive disclosure and recaps

Build multi-step slides one element at a time so the audience processes one new
thing at a time. Re-showing an identical figure later with fresh annotations is a
strong way to say "here is our remaining obstacle" without re-explaining context
(Ink re-shows the same code first to motivate refutation, later to mark the part
synthesis still has to solve).

Add a recap when the talk changes altitude (problem -> key idea, method ->
evaluation, results -> takeaway). A good recap reuses an earlier visual rather than
introducing a new one. If a "recap" also introduces new content (a theorem), be
aware it is doing two jobs.

## 12. Search-vs-reasoning (two-engine) division of labor

If the method mixes two engines (search + reasoning, learning + verification,
heuristic + exact), draw one diagram that assigns each sub-part to an engine and
state the principle out loud. This turns "we use several techniques" into "we use
the right technique for each part". Ink's decomposition tree solves scalar leaves
by search and derives structural parts deductively: "search only the scalar leaves;
derive everything structural." This is distinct from the method map (pattern 9),
which shows overall flow rather than the engine assignment.

## 13. Results answer the planted questions

Design evaluation slides around the audience's standing questions, in order, not
around paper subsections:

- **Usefulness**: what real tasks/datasets/domains does it cover? (Also pays off the
  motivation by answering "did you only test toys?")
- **Performance**: how does it do vs. alternatives?
- **Necessity**: ablations, mapping one-to-one onto the design choices from pattern 7.
- **Limits** (optional): where it breaks (Opera names its one timeout).

Every evaluation slide should pay off a claim made earlier.

## 14. Foundational reframing

A talk feels foundational when it hands the audience a new lens for a class of
problems, not just a solution to one example. State: the old framing, why it was
hard, the new abstraction, what becomes easier once it exists, and what else might
fit it. Form: "instead of solving ___ directly, we solve ___; this is useful
because ___."

- Opera: instead of designing an online algorithm, infer a spec from the offline
  program and synthesize code that preserves it.
- Ink: instead of reasoning about entire dataframes, reason about one row; instead
  of synthesizing a merge for the whole aggregation, synthesize a normalizer for the
  accumulator.

## 15. Slide craft

General rules (Hicks, Peyton Jones, Ernst) that both decks obey:

- **Say it twice (or thrice).** Speak an important point, show it as a figure, and
  make it readable as text, so the audience hears, sees, and reads it. Never leave a
  key claim as text alone.
- **The title is the point.** A slide's title carries its single most important
  message; if a pithier sentence is in the body, promote it to the title. Phrasing
  titles as the audience's question does this well.
- **No bullet-dump slides.** Lists are a fine outline for the speaker but dull for
  the audience. Convert points into figures, annotated code, or boxed statements.
- **No bare "Thanks!" slide.** The last slide summarizes the key points and stays up
  during Q&A, with pointers to more (a repo, a QR code, an artifact badge).

## 16. Outline-first process

How to build the talk without wasting effort:

1. Decide what you will say before making any slide; beautifying slides before the
   big picture exists produces throwaway work.
2. Outline top-down: section headers (mirroring the paper), then rough content, then
   slide breakdown. Keep the whole outline visible so you never blow the time
   budget. Budget about one slide per minute (faster for animations, slower for
   figures to explain).
3. Make placeholder slides: titles, speaker notes, and the code/figures you know you
   will reuse from the paper.
4. Prettify last, once the argument flows.

The time budget forces the cuts. When over time, decide what to expand and what
stays high-level using the purpose test (does this move a non-expert toward reading
the paper?).

## 17. Delivery

Content and structure are most of the battle; delivery closes it. Be enthusiastic
(Peyton Jones' most emphasized point): if you are not visibly excited, the audience
will not be. Rehearse to time so flow and timing are automatic. Study recorded talks
by speakers you admire (Hicks names Peyton Jones, Derek Dreyer, Ranjit Jhala) and
steal concrete moves.

## 18. Sources

- Michael Hicks, "How to Write a Conference Talk" (The PL Enthusiast, 2019):
  http://www.pl-enthusiast.net/2019/01/02/how-to-write-a-conference-talk/
- Simon Peyton Jones, "How to Give a Great Research Talk":
  https://simon.peytonjones.org/great-research-talk/ ; classic slides with John
  Hughes and John Launchbury:
  https://www.microsoft.com/en-us/research/wp-content/uploads/2016/08/giving-a-talk.pdf
- Michael Ernst, "Giving a technical talk":
  https://homes.cs.washington.edu/~mernst/advice/giving-talk.html
- Companion on the underlying paper: Simon Peyton Jones, "How to Write a Great
  Research Paper": https://simon.peytonjones.org/great-research-paper/
