---
name: research-talk-design
description: >-
  Design the story and structure of a research or technical conference talk, or
  turn a paper/project into a talk outline and narrative. Use this whenever the
  user is preparing a conference, research, or technical talk, presentation, or
  slide deck; wants help structuring a talk, building an outline or story,
  deciding what to cut, ordering slides, motivating a method, making a dense
  paper land with an audience, or fixing a talk that "feels like a list of
  components." Trigger even when the user does not say the word "story" or
  "skill", e.g. "I'm giving a talk on my paper", "help me structure my
  presentation", "how should I present this", "make a talk outline", "my slides
  are just bullet points", or "PLDI/POPL/NeurIPS/OSDI talk". This designs the
  narrative; it does not render slides.
---

# Research Talk Design

Help the user turn a paper or project into a **talk story**: an audience-centered
sequence of motivated questions, design choices, examples, and payoffs. The
output is an outline and per-section narrative notes, not finished slides.

The core belief behind everything here: a strong technical talk makes each design
choice feel like the forced response to an obstacle the audience just saw. It
does that with one anchor example carried throughout, one recurring method map, a
question-driven macro-structure, and each idea presented as problem -> intuition
-> object -> worked example -> payoff. Detail that does not move a mostly
non-expert audience toward reading the paper is a candidate for cutting.

## When you are invoked

Figure out where the user is and meet them there:

- **From scratch (have a paper/project, no talk yet):** run the full workflow below.
- **Have a draft talk that "isn't landing":** diagnose against the checklist in
  `references/skeleton-and-checklist.md` and the patterns in
  `references/patterns.md`, and propose targeted fixes rather than a rewrite.
- **Stuck on one part** (the opening, the challenge slide, what to cut, the
  ending): jump to the relevant pattern.

Ask for the paper (or its abstract + intro) and the **time budget** (a 15, 20, or
25 minute slot changes how ruthless the cutting must be; budget about one slide
per minute). If the user cannot share the paper, work from their verbal summary.

## Workflow: paper -> talk story

Do these in order. Each step is expanded, with examples and rationale, in
`references/patterns.md` (read it before giving detailed advice). Do not just
name the steps to the user; produce concrete content for their specific paper.

1. **Fix the purpose and the one-sentence takeaway.** The talk's job is not to
   cover every result; it is to make a mostly non-expert audience grasp the key
   idea and want to read the paper. Write the single sentence you want an
   attendee to repeat a week later. Everything else serves it.

2. **Extract the paper's spine and reuse it.** Pull the argument from the intro:
   world, problem, why no good solution exists, the key idea, why it works,
   evidence. Reuse this order, argument, and examples. You reconstruct for a live
   audience by cutting to essence and adding visual/example scaffolding, not by
   inventing a new argument.

3. **Choose the anchor example.** Pick one example that fits on a slide, contains
   the main difficulty, has a clear before/after, and can be revisited in every
   technical section. If the contribution has two kinds of outcome (e.g. succeed
   vs. prove-impossible), pick two anchors, one per outcome.

4. **Lay out the question-chain macro-structure.** Order the talk so each section
   answers a question the previous one planted, and phrase section titles as
   those questions:
   - Why should I care? (world + a concrete, quantified pain)
   - What exactly is the problem? (the formal goal)
   - Why is it hard? (the challenge)
   - What is the key idea? (the reframing)
   - How does it work? (the method map + components)
   - Does it work? (usefulness, performance, necessity)
   - What should I remember? (takeaway)

5. **Shape the structure to mirror the real guarantees.** If the method can say
   "no", return a partial answer, or fail-usefully, give that equal billing (a
   goal, a pipeline stage, a results number, an ablation). Do not hide the shape
   of the contribution.

6. **Design the background as a vocabulary ladder.** List the primitives the key
   idea needs that an outsider would not know; introduce each on its own slide in
   dependency order so the formal statement lands on defined vocabulary. End the
   background on the motivating pain, ideally a concrete quantified failure the
   tool would have caught.

7. **Make each design choice answer an obstacle, and plan to cash it out.** For
   every component, fill in: *naively we might try ___, but that fails because
   ___, so we introduce ___, which works because ___.* Plan the evaluation so it
   later removes exactly these choices (ablations), closing the loop.

8. **Derive the challenge by annotating the formal goal.** Rather than a
   disconnected list of "challenges", write the goal (or before/after code) once
   and highlight the specific fragments that make it hard.

9. **Design one recurring method map.** One diagram of the whole pipeline, reused
   to preview the method, mark transitions, and serve as the summary. Do not make
   a new diagram per section.

10. **Stage each technical idea as intuition -> object -> example -> takeaway, and
    ration formalism.** Keep only the correctness contract, the key reframing, and
    the soundness bridge; reference proofs and full rule sets for later readers.
    No abstraction should travel more than one slide without an example beside it.

11. **Plan progressive disclosure and recaps.** Build multi-step slides one
    element at a time; re-show a figure later with fresh annotations to mark
    remaining obstacles; add a recap when the talk changes altitude.

12. **Design results to answer the planted questions**, in order: usefulness
    (what real things did you test?), performance (vs. alternatives), necessity
    (ablations), and optionally limits.

13. **Add a foundational reframing.** State it as "instead of solving ___
    directly, we solve ___; this is useful because ___", so the method reads as a
    general lens, not a one-off trick.

14. **Apply slide craft, outline-first process, and delivery** (see the patterns
    file): say each key point in more than one modality, make titles carry the
    point, avoid bullet-dump slides, end on a content-bearing summary (never a bare
    "Thanks!"), build outline-first and slides-last, and rehearse with enthusiasm.

## Output format

Deliver a **talk story document**, not slide files:

- The one-sentence takeaway and the intended audience.
- A section-by-section outline using question titles, with, for each section: what
  the audience should believe by the end of it, the key visual or example, and a
  rough slide count against the time budget.
- The chosen anchor example(s) and where each recurs.
- The recurring method map (described).
- Notes on what to cut and what to keep as an expert-only aside.
- A short "risks / weak spots" list (transitions that may lose people, slides
  doing two jobs, claims not yet paid off).

Then offer to iterate on any single section in depth.

## Reference files

- `references/patterns.md` - the full pattern catalog with rationale and worked
  examples from two real talks (Opera and Ink). Read this before giving detailed
  guidance on any step above.
- `references/skeleton-and-checklist.md` - a ready-to-adapt 20-25 minute slide
  skeleton and a pre-finalization checklist. Use the checklist to diagnose an
  existing draft.

## Sources

The patterns distill two well-received talks plus widely used general advice from
Michael Hicks ("How to Write a Conference Talk"), Simon Peyton Jones ("How to Give
a Great Research Talk"), and Michael Ernst ("Giving a technical talk"). Links are
in `references/patterns.md`.
