# Calibration examples

These examples are invented and schematic. Adapt the amount of motivation and reordering to the reader's needs; do not treat the examples as fixed wording.

## 1. Technical explanation: motivation before architecture

Before: "We implement a local checker and a composition checker. The former verifies judgments and the latter checks their links. We reuse the composition checker across languages."

Better: "Checking a proof requires both validating its individual claims and establishing that they combine to prove the overall goal. We therefore use a language-specific checker for each claim and a shared checker for their composition. This separation also lets us reuse the composition checker across languages."

Why: The motivation prepares the design decision; reuse follows as a consequence instead of a disconnected feature.

## 2. Results: reveal the intended comparison

Before: "The two models succeed on the same tasks. Model A generates its derivation without assumptions. Model B needs three revisions and initially assumes most of its argument."

Better: "Although both models eventually succeed, their proofs reveal different levels of independent reasoning. Model A derives its proof on the first attempt, while Model B initially assumes most of its argument and needs three rounds of revision."

Why: Readers know why to attend to the following details. Preserve qualifications and exact numbers when editing actual research.

## 3. Business update: facts need a decision-relevant thread

Before: "The vendor deployed version 3.2 on Monday. Two users filed tickets. The dashboard has a new export option. A review is scheduled Friday."

Better: "The vendor's Monday release introduced an export option, but two users have reported issues. We'll review the tickets on Friday before deciding whether to recommend the feature to the team."

Why: Events become a coherent update with an implication and next decision. Use only when the supplied facts justify the relationship; do not invent causal links or next steps.

## 4. Email: show why the recipient is hearing this

Before: "I checked the schedule yesterday. The deadline is on Thursday. Several sections are still missing. Can you send your draft?"

Better: "Since the deadline is Thursday and several sections are still missing, could you send your draft today? I checked the schedule yesterday and can help identify what remains."

Why: The request and reason are prominent. Do not fabricate deadlines, status, or availability when drafting real correspondence.

## 5. Essay: observation should lead toward meaning

Before: "The trees were bare this morning. Yesterday it was windy. Autumn changes quickly. This reminded me of a story I read as a child."

Better: "Yesterday the trees still held their red leaves. After a windy night, I woke to find nearly all of them gone. The speed of that change brought back a story I had read as a child."

Why: The temporal contrast lets the reader experience the observation before interpreting it; it does not force a thesis sentence at the beginning.

## 6. Proposal: facts should support a choice

Before: "Option A costs less. Option B supports more integrations. Maintenance is also important. We recommend A."

Better: "We recommend Option A because its lower cost better fits our current needs. Option B supports more integrations, but we should weigh whether those integrations justify the additional cost and maintenance burden."

Why: The comparison is explicitly tied to the recommendation. In a real proposal, confirm that the recommendation is supported, rather than inserting reasons merely to improve prose.

## 7. Definitions: introduce a distinction when it matters

Before: "The rules define R(p,s,o), satisfying R(p,s,o) iff [[p]](s)=o."

Better: "Write R(p,s,o) when the supplied rules can derive that p produces o from state s. This expresses derivability, whereas [[p]](s)=o states the program's semantics. We require these to agree."

Why: Readers see the reason for the separate notation instead of assuming the symbols are interchangeable.

## 8. Unwarranted claims: repair reasoning, not just flow

Before: "We asked the generator for diverse rewrites, so the benchmark covers all important transformation types."

Better: "We asked the generator for varied rewrites. To characterize the accepted benchmark, we should report which transformation types actually appear and how frequently."

Why: A writing assistant should not turn a design intention into unmeasured evidence.

## Anti-patterns

- Do not force every paragraph into "challenge, insight, solution."
- Do not add "This is important because" unless the motivation is genuinely missing.
- Do not always put the main point first: narrative and reflective writing may deliberately delay it.
- Do not replace clear sentences with broad, promotional, or moralizing abstractions.
- Do not invent reasons, stakes, or causal links to achieve superficial cohesion.
- Do not demand lengthy transitions when word order or a concrete noun resolves the problem.

## 9. False causality disguised as a transition

Before: "The accepted programs range from 25 to 86 statements. Therefore, the benchmark offers broad coverage of reasoning challenges."

Better: "The accepted programs range from 25 to 86 statements, but program length alone does not establish diversity of reasoning challenges. To characterize that diversity, report the transformations and control-flow structures actually represented."

Why: The original transition manufactures support for a claim that the evidence does not establish.

## 10. Polished slogan vs. concrete distinction

Before: "Our framework sheds light on the hidden complexity of model reasoning and unlocks richer insights."

Better: "Two models can reach the same verdict while differing in whether they justify the intermediate steps. Recording those steps lets us distinguish their proof-construction behavior."

Why: Replace praise about the method with the specific observable distinction it provides.

## 11. Procedural fact stack vs. roles and purpose

Before: "The system constructs records, performs validation, enables refinement, and returns diagnostics."

Better: "A model submits a proposed proof. The checker validates its claims and their composition; if a step fails, it reports the error so the model can revise that step."

Why: An explicit actor, input, operation, and outcome makes the process comprehensible without extra length.

## 12. Overexplaining easy facts while skipping the hard link

Before: "The reports were submitted on Tuesday. Tuesday is the day after Monday. This gives us new information. Therefore, we should change the launch plan."

Better: "The Tuesday reports identify a failure in the payment flow, so launching before the issue is fixed would expose customers to failed checkouts. We should delay the release until the fix is verified."

Why: Spend words on the causal link that supports the decision rather than padding facts the reader already understands. Only use the better version when the report actually supplies that evidence.

## 13. Synonym drift and equal emphasis

Before: "The evaluation measures proof acceptance. The success rate summarizes accepted results. Derivational correctness is our key metric. This crucial measure provides vital insights."

Better: "We measure proof acceptance as the share of submitted proofs that pass verification. We separately measure derivational coverage, which records how much of each accepted proof the model derived rather than assumed."

Why: Use one name per distinct concept and explain what each metric adds. Do not add synonyms or adjectives in place of a distinction.
