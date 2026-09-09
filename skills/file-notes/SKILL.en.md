---
name: file-notes
description: "File annotation and backup-note conventions. Use this skill whenever you need to back up files/directories, back up before deleting or moving anything, create scripts/configs/data/output files, or produce any file that might be unintelligible later. Trigger scenarios: backup, before moving to trash, organizing a directory, deleting files, generating scripts (.ps1/.sh/.py), generating config/data/log files, producing result files, archiving, packaging. Core requirement: every backup ships with an explanatory note, and every produced file carries enough comments that a human (or a future AI) can tell what it is, why it exists, and how to use it. Skip for purely temporary intermediate files, or when the user explicitly says no comments are needed."
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

## Workflow

1. **Identify the operation**: is this "backup/delete" or "produce a file"?
2. **Backup case** → back up first, then write a `README.md` note in the backup directory (Rule 1).
3. **Produce case** → judge "will this be understandable later?"; if not, add comments/notes (Rule 2).
4. **Self-check**: afterwards ask — "opening this in three months, would I get it?" If not, add it.

## Notes

- **Backup and note go together** — a backup without notes isn't a backup.
- **Write the "why"**, not just the "what" — the reason often matters more than the content (e.g. "removed because the upstream repo no longer exists").
- **Write full paths** so they can be copy-pasted to restore.
- **Chinese or English is fine** — match the user's working language.

## Reminder for the model

This skill is a **habit convention** for keeping outputs understandable — it does not mean writing essays for every file. The core is one sentence: **backups carry notes, outputs stay understandable; useful when it helps, skipped when it's noise.**
