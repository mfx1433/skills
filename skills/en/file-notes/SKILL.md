---
name: file-notes
description: "File annotation and backup-note conventions. Use this skill whenever you need to back up files/directories, back up before deleting or moving anything, create scripts/configs/data/output files, or produce any file that might be unintelligible later. Trigger scenarios: backup, before moving to trash, organizing a directory, deleting files, generating scripts (.ps1/.sh/.py), generating config/data/log files, producing result files, archiving, packaging, wrapping up a task and cleaning up. Core requirement: every backup ships with an explanatory note, and every produced file carries enough comments that a human (or a future AI) can tell what it is, why it exists, and how to use it; also skip files you can avoid creating, never save a near-duplicate (>90% identical) of an existing file, and inventory your outputs at wrap-up and ask the user whether to clean them up. Skip for purely temporary intermediate files, or when the user explicitly says no comments are needed."
---

# File Annotation & Backup-Note Conventions

## Why this skill

Files an AI generates and backups it makes are **clear at the time and confusing later**. A few weeks on (or in a different conversation/agent), nobody knows:
- What is this backup, why was it removed, can it be restored?
- What does this script do, how do I run it, what does it depend on?
- What format is this data file, where did it come from, what do the fields mean?

**Goal: make AI-produced files and backups self-documenting**, so that later anyone (including a future AI) can open them and immediately understand — without archaeology.

## Core rules

### Rule 1: Every backup must ship with an explanatory note

**Any "back up first, then delete/move" operation** must drop a note file (usually `README.md`) into the backup directory, recording:

- **What it is** (which file/directory was backed up)
- **Original location** (where it was)
- **Why** (why it was backed up / why it was removed)
- **When** (timestamp)
- **How to restore** (how to put it back)

**Why**: a backup without notes becomes "junk you can't understand" — too risky to delete, impossible to use. It's a backup in name only.

**Template** (adapt to reality; don't fill it in word-for-word):

```markdown
# <backup directory name> — notes

> Backed up: <YYYY-MM-DD>
> Reason: <one sentence>

## Contents

### 1. `<directory/file name>`
- Original location: `<original path>`
- Contents: <what it is>
- Why backed up / removed: <why>
- How to restore: <how to put it back>

## How to restore

<one command or steps>
```

> If the backup directory holds several items, list them one by one as above; if there's only one, a short note is enough.

### Rule 2: Produced files must be understandable

**When creating any file that might need to be understood later**, make it self-explanatory. The test is simple:

> **"If I (or another AI) open this file three months from now, will I immediately know what it's for?"**
> If not → add a note.

By file type:

| File type | How to document it |
|-----------|-------------------|
| **Scripts** (.ps1/.sh/.py/.bat) | Header comment block: purpose, how to run, arguments, dependencies, caveats |
| **Config files** (.json/.yaml/.ini) | Comment key fields (if the format allows), or drop a `README.md` alongside |
| **Data/output files** (.csv/.txt/.json) | A note alongside, or a first-line comment: origin, field meanings, how it was generated |
| **Directories** | A `README.md` inside describing purpose and contents |
| **Temp/intermediate files** | Prefix the name with `tmp_` / `_`, or keep in a temp dir — no detailed notes needed |

**Script header template**:

```
# =====================================================================
#  <script name> — <one-line purpose>
#  Usage:       <how to run>
#  Arguments:   <what arguments>
#  Dependencies:<what it needs>
#  Notes:       <caveats/gotchas>
# =====================================================================
```

### Rule 3: When you can skip it

Avoid over-commenting and creating noise. These can be skipped or kept minimal:

- **Temp/intermediate files** (disposable) — though a self-explanatory name helps (e.g. `tmp_download.log`)
- **The user explicitly says no comments**
- **Self-explanatory content** (e.g. a file literally named `2026-09-09_meeting-notes.md`)
- **Standard convention files** (`.gitignore`, `LICENSE`)

The measure: **add notes when they clearly help; skip when they'd be pure noise.**

### Rule 4: Decide whether to create the file at all, before deciding how to annotate it

Rules 1–3 all **assume the file already exists**. But the more common waste is **creating files that never should have existed**.

**Before creating a file, ask three questions:**

1. **Can it be skipped?** — Can this go into an existing doc, or straight into the answer?
2. **Can it be reused?** — Edit an existing file instead of creating a near-copy.
3. **Is it >90% identical to something that already exists?** — Then **do not save a second copy**. Put the difference in the documentation instead (e.g. "swap dropdowns ①② to `xxx`").

**When the task wraps up, take stock:**

- List every file this task produced
- Mark which are **one-off**: installers, transient logs, spent scripts, files superseded by a later version
- **Ask the user whether to clean them up** — never delete unilaterally

**Why this rule exists**: annotation conventions govern "what you keep must be understandable" — they say nothing about **whether you should keep it**. Doing only the former gives you "every file beautifully commented, and far too many files to want to read" — **bloated *and* confusing**. Do both and the output is **few and clear**.

**A real example**: three variants of the same workflow were each saved as their own JSON. Two were **95.5% byte-identical**, differing only in one model name. The right move was one file plus a line in the docs: "swap these two dropdowns."

## Workflow

1. **Identify the operation**: is this "backup/delete" or "produce a file"?
2. **First decide whether to create a file at all** (Rule 4): skip if you can, reuse if you can, never save a >90%-identical copy.
3. **Backup case** → back up first, then write a `README.md` note in the backup directory (Rule 1).
4. **Produce case** → judge "will this be understandable later?"; if not, add comments/notes (Rule 2).
5. **Self-check**: afterwards ask — "opening this in three months, would I get it?" If not, add it.
6. **Wrap-up inventory** (Rule 4): list what was produced, flag the one-off files, ask the user whether to clean up.

## Notes

- **Backup and note go together** — a backup without notes isn't a backup.
- **Write the "why"**, not just the "what" — the reason often matters more than the content (e.g. "removed because the upstream repo no longer exists").
- **Write full paths** so they can be copy-pasted to restore.
- **Chinese or English is fine** — match the user's working language.
- **Creating fewer files matters more than writing more comments**: an unnecessary file is a burden no matter how well annotated.

## Reminder for the model

This skill is a **habit convention** for keeping outputs understandable — it does not mean writing essays for every file.

Two core sentences:
1. **Backups carry notes, outputs stay understandable** — useful when it helps, skipped when it's noise.
2. **Don't create it if you can avoid it; if you do, make it understandable** — few and clear beats complete and unreadable.
