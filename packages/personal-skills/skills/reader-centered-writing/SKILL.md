---
name: reader-centered-writing
description: Use when a user struggles to follow a passage or wants to improve its logical flow, motivation, or clarity of reasoning. Diagnose missing connections, unexplained concepts, and overly compressed or LLM-like prose, then suggest targeted revisions.
---

# Reader-Centered Writing

## Core principle

Write for the reader's unfolding understanding, not merely the author's inventory of facts. At each consequential transition, readers should be able to answer **why am I being told this now, how does it connect to what I know, and why should I care?**

Clear writing does not require explaining everything. It requires supplying the **right context, motivation, and logical links at the moment readers need them**. Optimize for the reader's ability to follow the intended movement of thought, not for maximum explicitness or a polished-sounding surface.

## Workflow

1. **Identify audience, purpose, and genre.** Determine what readers likely know, what they want or need, and what the writer wants them to understand, feel, decide, or do. Preserve the author's voice and constraints. For technical or file-based material, consult surrounding passages and evidence, not isolated snippets, when flow is at issue.
2. **Recover the intended throughline.** State privately in one sentence what the passage is trying to accomplish. For a section, sketch how its paragraphs advance that goal. If the purpose is ambiguous, flag it rather than inventing one.
3. **Locate reader friction.** Find where the reader must supply an unstated premise, infer a change in topic, guess an undefined term, wait too long for the point, or wonder why a detail matters. Differentiate a missing *connection* from an actually unsupported *claim*.
4. **Choose the smallest structural fix.** Reorder statements, add one motivated bridge, replace a vague subject, define a term in context, move detail to its point of use, or split a sentence that does too many jobs. For larger structural problems, propose an outline before line edits.
5. **Refine locally.** Use direct subjects and verbs; keep referents and pronouns clear; make comparisons explicit; adjust pacing and sentence length to the content. Remove hollow abstraction, repetitive summaries, and unearned rhetorical flourishes. Do not introduce generic transitional filler or inflate concise good prose.
6. **Check fidelity and effect.** Preserve facts, evidence, uncertainties, causality, intended emotional tone, and technical precision. Do not invent anecdotes, stakes, motivations, data, guarantees, or reader reactions to improve flow. Keep persuasion accurate and respectful rather than manipulative.
7. **Respond proportionally.** For a pinpointed passage, usually provide the main diagnosis, a ready-to-use revision, and a concise feedback comment if reviewing someone else's work. For a larger document, identify the structural throughline and high-impact revisions first. If the passage works, explain why instead of manufacturing edits.

## What creates good flow

The principle is **reader questions drive information order**. Before adding a fact, definition, example, procedure, or result, ask which live question it answers. The best order may differ by genre:

- **Explanation or research:** goal or question -> why it is nontrivial -> insight -> mechanism/evidence -> implication.
- **Proposal or recommendation:** need or opportunity -> recommended action -> reasons/evidence -> tradeoffs -> next step.
- **Update or memo:** what changed -> why it matters -> supporting details -> required action.
- **Email or request:** appropriate context -> clear request or message -> relevant reason -> next step. Get to the point earlier when recipients are busy.
- **Essay, story, or personal writing:** establish context, curiosity, or emotional stakes -> develop the experience or observation -> reveal its significance at a deliberate pace. Do not spoil intentional discovery merely to put a thesis first.

These are flexible progressions, not templates to impose on every paragraph. Some good writing rightly withholds a conclusion, opens with an example, or offers a terse definition without preamble.

## Frequent failure modes and repairs

- **Facts without motivation:** A list of features, statistics, or events has no clear purpose. Establish the reader's question or stakes; then select and order the facts that answer it.
- **Abrupt subject changes:** Consecutive sentences or paragraphs are individually sensible but their relationship is hidden. Name the shift (problem to response, observation to implication, method to evaluation, concern to request), preferably in the actual sentence rather than a decorative transition.
- **Buried main idea:** Readers reach the end before realizing what the details were meant to show. State the framing claim earlier when it helps them interpret evidence. Preserve delayed revelation when it is integral to the genre.
- **Unexplained inference:** A sentence moves from evidence to a conclusion without the missing reasoning or caveat. Supply the warrant, soften the conclusion, or mark it unsupported.
- **Unmotivated mechanism:** Details of tools, steps, implementation, or process appear before the reader understands what the mechanism achieves. Explain the goal and role before the plumbing.
- **Premature terminology:** A definition, acronym, or metric appears long before it matters, or notation arrives before its meaning. Introduce it when needed, give a brief intuitive explanation, and distinguish it from nearby concepts.
- **Unclear referents and comparisons:** Phrases such as "this failure," "these results," "it," and "they" force readers to search backward. Name the thing; specify compared populations and denominators if relevant.
- **Overcompressed sentences:** A single sentence covers setup, assumptions, mechanism, and outcome. Divide by distinct rhetorical jobs, not an arbitrary word limit.
- **Slogans and meta-announcements:** Replace "the most important takeaway is that" or catchy abstractions with the actual point when possible. Retain purposeful rhetoric when the audience and genre call for it.
- **Excessive signposting:** Repeated "this matters because" sentences can be as tiring as missing connections. Make the relationship clear through order and word choice; add a bridge only where necessary.

## Diagnosing "LLM-flavored" prose

Treat "LLM-flavored" as a **reader-experience critique, never an inference about authorship**. These traits also occur in human drafts, and AI-generated writing can avoid them. Identify the actual reading burden before editing. Frequent signals include:

1. **Local fluency, global incoherence:** Individual sentences read smoothly but the paragraph lacks a throughline; each sentence could be swapped without changing the apparent argument. Recover the causal or explanatory sequence.
2. **High information density, low explanatory density:** Terms, mechanisms, and results accumulate faster than their meaning, motivation, or connection is established. Give important ideas space; cut low-priority facts rather than adding padding.
3. **Premature jargon and abstract-noun stacks:** Terms like *derivational coverage*, *semantic evidence*, or *framework instantiation* appear before an intuitive reason to need them. Use a concrete problem and actors/actions first; define the specialized term at its first useful appearance.
4. **Mechanism before purpose:** A paragraph describes how a process operates before stating what it is for or what difficulty it addresses. State the intended outcome and the obstacle, then the machinery.
5. **Unlicensed transitions:** *Thus*, *therefore*, *consequently*, *crucially*, and *this enables* imply an inference that the text has not earned. Supply the missing premise, qualify the conclusion, or remove the connective.
6. **Hollow significance claims:** Phrases such as *this highlights the importance of*, *provides valuable insights*, *robust and comprehensive*, *in practice*, or *plays a crucial role* substitute evaluation for evidence. Say exactly what changed, for whom, or under which conditions.
7. **Slogan-like topic sentences:** *Every gap stays visible* or *our approach bridges the divide* sound memorable but conceal the claim. Prefer concrete topic sentences that tell the reader what follows and why.
8. **Vague references and agent switches:** *This failure*, *such cases*, *the resulting framework*, or abrupt shifts from *we* to *the model* hide what acts on what. Repeat the necessary noun and make roles, inputs, actions, and outputs explicit.
9. **Artificially symmetric structure:** Three "key pillars," mirrored contrasts, and *not only X but also Y* appear without a genuine conceptual distinction. Keep structures only when each part contributes a different necessary idea.
10. **Repetitive rephrasing rather than progression:** A sentence restates the previous claim with new abstract synonyms instead of giving evidence, explanation, complication, or implication. Delete it or advance the thought.
11. **Context-free numbers and comparisons:** Percentages appear without their denominator, baseline, or the question they answer. Name what is counted, compared, and why that comparison matters.
12. **Misallocated explanation:** The text explains self-evident matters repeatedly but compresses the one difficult inference or transition that readers need help with. Spend explanatory effort where the reader is likely to stumble, not where prose is easiest to expand.
13. **Synonym drift:** One technical or conceptual idea is repeatedly renamed to sound varied (e.g., *acceptance*, *correctness*, *success*), forcing readers to guess whether these are identical or different. Reuse precise terms consistently unless there is a real distinction.
14. **Flat emphasis and uniform promotional cadence:** Every feature is *key*, every result is *crucial*, and every paragraph ends in a broad payoff. Rank ideas, vary rhythm, use ordinary verbs, and match confidence to evidence.

The most revealing combination is often **compression of reasoning plus inflation of presentation**: dense jargon and facts with too little explanation, surrounded by verbose generic framing. Prefer eliminating low-value text and explicitly connecting high-value ideas, rather than merely shortening or lengthening the paragraph.

Avoid replacing one synthetic pattern with another. In particular, do not mechanically add a motivation sentence, an "important takeaway," or a "this matters because" after every fact. Repair the order and connection of thoughts first. Concision is good when the reader already has the required context; density becomes harmful when it forces readers to reverse-engineer unstated premises.

When commenting on a passage, do **not** conclude that a model wrote it, or say only "sounds AI-generated." Name the defect and show the reader's experience: "I understood the metric only after finishing the paragraph; could we first say which question it answers?"

## Reader-oriented checks

At the sentence level: What does the reader know at this point? What new question does this sentence answer? Is a term introduced before use? Are pronouns and contrasts unambiguous?

At the paragraph level: Is there a recognizable purpose? Is the key detail connected to that purpose? Does the order help readers interpret it? Have the author and reader drifted apart?

At the document level: Does each section prepare a reason for the next? Are key definitions, examples, and evidence placed near where readers need them? Does pacing fit the audience and desired effect?

## Genre-sensitive guardrails

- **Technical and scientific:** Preserve mathematical meaning, assumptions, boundaries, and measured vs. inferred conclusions. A smoother sentence must not transform a possibility into a guarantee. Explain when specialized notation is necessary.
- **Professional and persuasive:** Make the requested action and justification visible; acknowledge meaningful costs and counterarguments. Do not invent urgency or exaggerate benefits.
- **Personal and emotional:** Preserve authenticity, nuance, and the intended relationship. Do not impose corporate efficiency or artificial positivity on intimate writing.
- **Creative or narrative:** Allow suspense, ambiguity, rhythm, and delayed interpretation when deliberate. Seek continuity of attention, not necessarily an upfront thesis.
- **Feedback on another author's draft:** Describe the concrete reader burden and propose one actionable fix. Prefer collegial, non-prescriptive comments over broad judgments that prose "sounds like AI."

Keep suggested writing natural, compact, and appropriate to its context. Avoid en dashes and em dashes when writing for a user who prefers simple punctuation.

See [examples.md](references/examples.md) for genre-spanning examples and counterexamples.
