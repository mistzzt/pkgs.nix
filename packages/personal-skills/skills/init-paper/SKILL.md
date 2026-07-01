---
name: init-paper
description: Initialize (or improve) a CLAUDE.md for an academic paper repository written in LaTeX. Use this skill whenever the user asks to "set up", "bootstrap", "initialize", "create", or "improve" a CLAUDE.md / agent instructions file in a LaTeX paper repo, or mentions onboarding Claude Code to a research paper codebase. Also trigger when the user is in a `.tex`-heavy repo and asks Claude to "get oriented" or build a section/figure map for future agents.
---

# Initialize CLAUDE.md for a LaTeX Paper Repository

Produce a high-signal `CLAUDE.md` so a future Claude Code instance can orient itself in a paper repo in seconds. Future agents need three things fast: how to build the PDF, what the paper claims and where those claims live, and where the key technical artifacts (rule figures, DSLs, algorithms, result tables) are.

A paper repo is not a software project. Skip generic engineering advice — it crowds out what matters.

## Workflow

### 1. Survey

- If `CLAUDE.md` exists, read it and plan to _improve_ it, not overwrite.
- Read `README.md` and pull anything non-obvious (build quirks, datasets, arXiv ID).
- Find the main `.tex` (usually `main.tex`/`paper.tex`) and trace its `\input{...}` / `\include{...}` structure.
- Identify the build tool (`latexmk`, `Makefile`, `tectonic`, `build.sh`, Nix/Docker) and bib tool (`bibtex`/`biber`).
- **Ignore `docs/`.** By convention, `docs/` holds whatever the user is currently working on (progress notes, scratch plans) — it's unrelated to the paper sources. Don't read its contents and don't reference it from CLAUDE.md. Only `.tex` files matter for the section/figure map.

Use Glob/Grep directly; no subagents needed.

### 2. Ask two questions (unless already answered)

Before asking, check whether the user has already answered these in the current request or earlier in the conversation. If so, record the answers and skip the interview — don't re-ask.

Otherwise ask both upfront, in one short message:

1. **Build locally?** "Should future Claude instances build the LaTeX locally (e.g., `latexmk -pdf`), or skip building and only edit sources?" Running `latexmk` on an unfamiliar machine can hang, pull in a huge TeX Live install, or fail noisily — get explicit consent.
2. **Target venue area?** "What's the general target venue (e.g., POPL/PLDI, NeurIPS/ICML, OSDI/SOSP)?" You only need the area, not the exact conference — it helps future agents calibrate tone, length norms, and what counts as a "contribution".

### 3. Read the intro, extract the claim structure

Open the intro (e.g., `intro.tex`). Extract:

- The one-sentence thesis.
- The contributions list (often verbatim: "Our contributions are…").
- For each contribution, **which later section backs it up.** Intros usually cross-reference ("We formalize X in §3, evaluate on Y in §6") — that mapping is the point.

If the intro doesn't spell out the mapping, infer from section titles and tag inferred entries `(inferred)`.

### 4. Section map

Partition the paper into logical parts using its actual section titles. Most systems/PL/ML papers cluster into: overview/motivation, formalism/DSL, algorithm/synthesis, verification, implementation, evaluation, related work, appendix. Group the real sections under whichever of these apply — don't force the template.

For each section record: number, title, file path, one-line description of what's _actually_ in it (not a restatement of the title).

### 5. Index technical figures/tables

Two kinds of figures exist; only one matters here:

- **Image figures** (plots, screenshots, system diagrams) — skip. Discoverable, rarely edited.
- **Technical figures** — inference rules, grammars, pseudocode, semantic reductions, key tables. Index these.

**Use the LaTeX `\label{...}` as the canonical identifier.** Figure numbers drift every time a section is added; labels don't. Grep for `\label{` inside `\begin{figure}`/`\begin{table}`/`\begin{algorithm}` blocks (and in dedicated `figures/*.tex` files). For each entry, record: label, one-line caption gist, file path, and the section that discusses it. If a figure has no label yet, note that as an action item rather than inventing a name.

While scanning labels, also note the repo's **labeling/referencing convention** and record it in the "Conventions" section of CLAUDE.md:

- Does the repo use `cleveref` (`\cref`/`\Cref`) or plain `\ref`? This changes how new labels must be introduced — with `cleveref`, the _type_ of the referent (Figure vs. Table vs. Algorithm) is inferred, and using the wrong label prefix can produce wrong output.
- Does it use typed labels like `\label[example]{ex:foo}` (cleveref's optional category argument, common with `acmart` and `thmtools`)? If so, new labels must follow the same pattern or cross-references break silently.
- Is there a label-prefix convention (`fig:`, `tab:`, `alg:`, `sec:`, `thm:`, `ex:`, `lem:`, `eq:`)? Record the prefixes actually in use so future agents match them.

These look like nitpicks but they're load-bearing in `acmart` and similar classes — a future agent adding a figure without following the convention will produce a document that builds but cites things incorrectly.

### 6. Write (or update) CLAUDE.md

Use the structure below. Keep it tight.

```markdown
# <Paper short name>

<One-sentence thesis.>

Target venue area: <e.g., "PL (POPL/PLDI)">.

## Build

<Either: exact command, output PDF path, gotchas.
Or: "Do not build locally — the user handles builds.">

## Key claims → sections

1. <Contribution> — §<N> (`foo.tex`)
2. ...

## Section map

- **Overview** — §1–2
  - §1 Introduction — `<file>` — <one line>
- **Formalism** — §3
  - ...
- **Evaluation** — §6
  - ...

## Key technical figures

- **`fig:typing-rules`** — typing rules — `<file>` — §3.2
- **`fig:grammar`** — DSL grammar — `<file>` — §3.1
- **`tab:benchmarks`** — benchmark results — `<file>` — §6.2

## Conventions worth knowing

<Only if non-obvious. E.g., "macros live in `macros.tex`, don't redefine in section files."
Omit the section entirely if nothing surprising came up.>
```

### 7. Present

Write (or update) `CLAUDE.md` at the repo root (unless the user specified a different output path, e.g. for a dry-run). Then in chat, give the user a short summary covering:

- Where you wrote the file.
- If you _updated_ an existing `CLAUDE.md`, the substantive changes (added/removed/rewritten sections) — not a full rehash of the file.
- The build decision recorded.
- Any `(inferred)` claim→section entries, figures without `\label`s, unresolved `\cite{...}` placeholders, and surprising conventions you surfaced.

Don't paste the entire file back into chat — the user can open it.

## What to leave out

Common failure modes — avoid:

- **Generic engineering advice** ("write clear commits", "add tests", "helpful error messages"). Paper repos don't have features or users in that sense.
- **Security boilerplate** ("never commit API keys"). Not relevant here.
- **Full file trees.** `ls` does that.
- **Restating section titles.** "§4 Synthesis describes synthesis." Useless — leave the description off instead.
- **Every figure.** Only technical ones.
- **Meta-commentary** ("this file was generated by…").

## Improving an existing CLAUDE.md

Don't overwrite. Read what's there, check each target section above for presence/accuracy/staleness (file paths especially), and propose a diff. Preserve the user's voice and any custom sections (collaborator notes, todos) unless clearly stale.
