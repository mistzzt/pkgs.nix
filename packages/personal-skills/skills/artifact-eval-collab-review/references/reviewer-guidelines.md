# [OOPSLA 2026 Artifact Reviewer Guidelines](https://2026.splashcon.org/track/splash-2026-artifact-evaluation#Reviewer-Guidelines)

Artifacts are an important product of the scientific process, and it is your goal, as members of the AEC, to study these artifacts and determine whether they meet the expectations laid out in the paper and adequately support its central claims.

## General guidelines and advice

Please keep in mind the following general guidelines and advice:

- Artifact evaluation is a collaborative process with the authors. Our goal is not necessarily to find flaws with the artifact, but to try to the best of our ability to validate the artifact’s claims. This means that back-and-forth discussion is always a good idea if there are issues, particularly with installation.
- Artifact evaluation is not an examination of the scientific merits of the paper. In other words, it is within scope to evaluate the artifact (towards the badges), but not to evaluate the paper itself.

In cooperation with the authors, and without sacrificing scientific rigor, we aim to accept all artifacts which support the claims laid out in the paper.

## Badges and Acceptance Criteria

We will be awarding four different kinds of badges: Available, Functional, Reusable, and Results reproduced. See the Badges tab for the formal requirements and how they relate.

## Overview of the Process

### Milestone 0: Bidding

During the initial bidding phase, you will examine the list of papers, and place bids for the artifacts that most closely match your research background, interests, and experience. Based on your bids, and depending on which paper authors choose to submit artifacts, we will assign you 3-5 artifacts to review.

After artifacts are assigned, the evaluation process is organized as the following milestones:

### Milestone 1: Kick-the-Tires

Research software is delicate and needs careful setup. In order to ease this process, in the first phase of artifact evaluation, you will be expected to at least install the artifact and run a minimum set of commands (usually provided in the README by the authors) to sanity check that the artifact is correctly installed.

Here is a suggested process with some questions you can try to answer.

After reading the paper:

- Q1: What is the central contribution of the paper?
- Q2: What claims do the authors make of the artifact, and how does it connect to Q1 above?
- Q3: Can you locate the specific, significant claims made in the paper (such as figures, tables, etc.)?

After installing the artifact:

- Q4: Are you able to install and test the artifact as indicated by the authors in their “kick the tires” instructions?
- Q5: Are there any significant modifications you needed to make to the artifact while answering Q4?
- Q6: For each claim highlighted in Q3 above, do you know how to reproduce the result, using the artifact?
- Q7: Is there anything else that the authors or other reviewers should be aware of?

During the process, you can leave a comment on HotCRP indicating success, or ask the authors questions. These questions can concern unclear commands, or error messages that you encounter. The authors will have a chance to respond, fix bugs in their artifact or distribution, or make additional clarifications. Errors at this stage will not be counted against the artifact. Remember, the evaluation process is cooperative!

### Milestone 2: Evaluating functionality

After the kick-the-tires phase, you will perform an actual review of the artifact.

During this phase, here is a suggested list of questions to answer:

    - Q8: Do the results of running/examining the artifact meet your expectations after having read the paper? This corresponds to the criterion of consistency between the paper and the artifact.
    - Q9: Is the artifact well-documented, to the extent that answering questions Q4–Q8 is straightforward? (Note: by well-documented, for this stage, we are generally considering only the README and instructions – we don’t mean that the code itself needs to be documented. That would matter only for reusability if the intention would be to modify the code in some way.)

In unusual cases, depending on the type of artifact and its specific claims, questions Q1–Q9 may be inappropriate or irrelevant. In these cases, we encourage you to disregard our suggestions and review the artifact as you think is most appropriate.

### Milestone 3: Evaluating reusability

You will evaluate artifacts for reusability in new settings. To evaluate reusability, the following three initial questions are suggested for all artifacts:

    - Q10: If you were doing follow-up research in this area, do you think you would be able to reuse the paper as a baseline in your own work?
    - Q11: Is the code released via an open source license (e.g., released with an OSI approved license)? Is it made publicly available on a platform such as GitHub, GitLab, or BitBucket?
    - Q12: Does the artifact have clear installation instructions?

To help you evaluate proof artifacts, the remaining questions are different for traditional (software) artifacts and for proof artifacts. For traditional software artifacts:

    - Q13a: Are you able to modify the benchmarks/artifact to run simple additional experiments, similar to, but beyond those discussed in the paper?

For proof artifacts, instead of Q13a, we suggest answering:

    - Q13b: Does the proof artifact contain definitions and proofs that can be used in other projects? (Examples of such artifacts include Rocq or Isabelle proofs and plugins.)
    - Q14: Does the artifact clearly state all environment dependencies, including supported versions of the proof assistant and required third-party packages?
    - Q15: Are all proofs claimed as reusable complete? (no “admit” in Rocq or “sorry” in Lean/Isabelle)

### Milestone 4: Evaluating reproducibility

The goal of this milestone is to reproduce all the significant claims made in the paper using the artifact, only excluding claims if there are very good reasons why they cannot be reproduced.

For traditional software artifacts:

    - Q16: Does the artifact provide evidence for all the significant claims you noted in Q1-3? Which claims are you able to reproduce and which are you not able to reproduce?
    - Q17: What do you expect as a reasonable range of deviation, e.g., for experimental benchmarking results? Are your results within this range?

For proof artifacts, instead of Q16-17 we suggest answering:

    - Q16b: Can you locate and map all definitions and theorems to their mechanization? Were you able to understand the mechanized definitions and theorem statements?
    - Q17b: Does the artifact contain undocumented assumptions or unfinished proofs?
    - Q18b: Do the mechanized definitions and theorems correspond precisely to those in the paper? If not, are the points of departure justified? Does the artifact agree with everything that the paper claims it does?

### Milestone 5: Writing reviews and discussion

Write a review by drawing on your answers to Q1–Q17. Make sure to include a specific recommendation of whether to award a badge, and of which badge(s) to award. Once you submit your draft review, we will make all reviews public, so you have a chance to discuss the artifact with other reviewers and the chairs, and reach a consensus. You should feel free to change your mind or revise your review during these discussions.

## Common issues

### In the kick-the-tires phase

    - Overstating platform support. Several artifacts claiming the need for only UNIX-like systems failed severely under macOS — in particular those requiring 32-bit compilers, which are no longer present in newer macOS versions. We recommend future artifacts scope their claimed support more narrowly.
    - Missing dependencies, or poor documentation of dependencies. The most effective way to avoid these sorts of issues ahead of time is to run the instructions independently on a fresh machine, VM, or Docker container.

### In the full review phase

    - Comparing against existing tools on new benchmarks, but not including ways to reproduce the other tools’ executions.
    - Not explaining how to interpret results. Several artifacts ran successfully and produced the output that was the basis for the paper, but without any way for reviewers to compare these for consistency with the paper. Examples included generating a list of warnings without documenting which were true vs. false positives, and generating large tables of numbers that were presented graphically in the paper without providing a way to generate analogous visualizations. We recommend to use scripts to generate data and experimental figures. This fully automated approach may be a bit more costly to setup, but you won’t have any copy/pasting issue for your paper, and regenerating data is heavily simplified.
