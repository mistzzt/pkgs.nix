# Evaluation Runbook: [Artifact Name]

## Context

- Artifact:
- Paper:
- Commit/version:
- Platform (OS/arch):
- Hardware constraints:
- Reviewer:
- Date:

## Kick-the-Tires

### Setup

Commands:

```bash
# Setup commands here (docker pull, env init, dependency install, etc.)
```

- Expected: [what success looks like]
- Result:
- Notes:

### Sanity check

Commands:

```bash
# Minimal run command from artifact docs
```

- Expected: [expected output/behavior]
- Result:
- Notes:

### Kick-the-tires questions

- Q1 (central contribution):
- Q2 (artifact claims):
- Q3 (significant claims to reproduce):
- Q4 (install/test success):
- Q5 (modifications needed):
- Q6 (reproduction path clear):
- Q7 (other notes):

### Author questions (if blocked)

1.

---

## Functionality

For each claim group below: run the commands, record results, and note any deviations from expected output.

### [Claim: RQ1 / Table 1 / Figure X]

Setup (if needed):

```bash
```

Commands:

```bash
```

- Expected output: [file path, console output, or success signal]
- Expected runtime: [estimate]
- Result:
- Output matches paper: [yes / partially / no]
- Notes:

### [Claim: RQ2 / Table 2 / ...]

Commands:

```bash
```

- Expected output:
- Expected runtime:
- Result:
- Output matches paper:
- Notes:

<!-- Repeat for each claim -->

### Functionality questions

- Q8 (outputs match paper expectations):
- Q9 (documentation clarity):

---

## Reusability

### Agent code-review findings

<!-- Agent fills this section by reading the source code -->

**Architecture:**

**Documentation quality:**

**Extension points:**

**Dependency clarity:**

**License and availability:**

### Reviewer notes

<!-- User adds observations here -->

### Reusability questions

- Q10 (reusable as baseline):
- Q11 (open source license / public availability):
- Q12 (clear installation instructions):
- Q13 (able to run additional experiments):

---

## Reproducibility (synthesis)

Summarize reproduction evidence from the functionality section above.

- Q16 (which claims reproduced):
- Q17 (deviation range and acceptability):

---

## Badge Worksheet

| Badge              | Evidence summary | Decision |
| ------------------ | ---------------- | -------- |
| Available          |                  | Pending  |
| Functional         |                  | Pending  |
| Reusable           |                  | Pending  |
| Results Reproduced |                  | Pending  |

## Author Questions (if blocked)

1.
2.
3.
