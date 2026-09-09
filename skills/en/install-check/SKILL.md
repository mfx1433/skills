---
name: install-check
description: "Check-before-install conventions for software, tools, and dependencies. Use this skill whenever you need to install, download, or upgrade anything (CLI tools, libraries, dependencies, applications), or when something is missing and needs installing. Trigger scenarios: install, set up, download, upgrade, update a tool, missing dependency, command not found, install an extractor, install a runtime. Core requirements: before installing, first check whether it is already present on the machine (if usable, never reinstall); then look up the latest version; choose a sensible method; get user confirmation before acting; and install to a predictable location. Avoid duplicate installs, outdated versions, unreachable install paths, and installing without asking."
---

# Check-Before-Install Conventions

## Why this skill

**Real lesson**: on the same machine, a 7z extractor was downloaded and installed **twice** — because each new conversation had no idea it had been installed before, and never checked what was already present (a full 7-Zip and WinRAR install already existed elsewhere). This class of problem includes:

- **Duplicate installs** (installing again what's already there — wasted time and space)
- **Outdated versions** (not checking for the latest, installing an old build)
- **Wrong location** (installed to a temp dir, unfindable next time, so it gets installed again)
- **Installing without asking** (the user only asked a question, and something got installed)

**Goal of this skill: before installing anything, check first, ask second, install last.**

## Core flow (in order)

### Step 1: Check whether it's already installed (most important!)

**Before installing, confirm whether the system already has it.** If it does, just use it — **never reinstall**.

How to check per platform:

| Platform | How to check |
|----------|-------------|
| **Windows** | `where <command>` / `Get-Command <command>`; `winget list <name>`; common install paths (`C:\Program Files\...`, `%LOCALAPPDATA%\Programs\...`, custom drives like `D:\...`); the registry when needed |
| **macOS** | `which <command>`; `brew list`; check `/Applications`, `/usr/local/bin` |
| **Linux** | `which` / `command -v`; `dpkg -l` / `rpm -q`; `apt list --installed` |

**Key point**: don't check only PATH! Many tools live outside PATH (e.g. `D:\7z`), so search via multiple routes. If nothing is found, say "not detected" rather than assuming it's absent.

### Step 2: Find the latest version (via web-research)

When you need to know the latest version, **call the web-research skill** — trace back to **primary sources** (official release pages, official APIs, official docs), not memory or second-hand articles.

> Example: to find a tool's latest version → check its official release page/API, not "I think it's 2.x".

### Step 3: Decide how to install

In priority order:

1. **Already present on the system** → just use it, don't install (covered by Step 1)
2. **Package manager** → prefer the system's package manager (clean, easy to upgrade)
   - Windows: `winget` / `choco` / `scoop`
   - macOS: `brew`
   - Linux: `apt` / `dnf` / `pacman`
3. **Official installer** → download from official channels (avoid third-party sites)
4. **Build from source** → last resort

### Step 4: Tell the user, get confirmation, then install

**Don't install unilaterally.** First state:
- Whether the system already has it (and recommend using that)
- What needs installing, which version, by what method, and where
- Then **wait for the user's confirmation** before acting

> Exception: when the user has explicitly asked "please install X", you may proceed — but **still do Step 1's check first** (it may already be installed).

### Step 5: Install to a predictable location + record it

- **Install to a consistent, predictable location** (system PATH, the package manager's default, or a fixed tools directory) so it doesn't get lost.
- If you install something outside PATH, **note its path** for the user so it's reusable later.
- Optional: keep an installed-tools list (e.g. `installed-tools.md`) recording what was installed, the version, the path, and why.

## Common pitfalls

- **Concluding from PATH alone**: the tool may live elsewhere — check several ways.
- **Downloading the same tool twice**: especially across new conversations — **always check before installing**.
- **Reporting versions from memory**: versions change — **check the official source**.
- **Installing without asking**: installation is a system-level action — **ask first**.
- **Installing to a temp directory**: unfindable next time, so it gets installed again.

## Reminder for the model

The core of this skill is one sentence: **before installing, check what the system already has (if usable, never reinstall); look up the latest version via web-research; confirm before installing; install somewhere findable.**

Don't rush to download — **first check whether it's already there.**
