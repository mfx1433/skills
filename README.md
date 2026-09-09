# Skills

[![skills.sh](https://skills.sh/b/mfx1433/skills)](https://skills.sh/mfx1433/skills)

> My personal collection of Agent Skills, built on the open [Agent Skills](https://skills.sh/) ecosystem.
> Author: [@mfx1433](https://github.com/mfx1433) | License: MIT
>
> **Bilingual** — every skill ships in both English and Chinese, in separate `en/` and `zh-cn/` folders.

**English** | [中文](#skills-中文)

---

## What is this

A collection of AI Agent Skills I wrote / customized. Each skill is a **reusable set of instructions** — once installed, the agent follows it automatically whenever the situation matches.

The point is not to add features, but to fix **failure modes I kept hitting**: answering from stale memory, leaving unreadable files behind, and installing the same tool twice.

Every skill is provided in **English** (`skills/en/`) and **Chinese** (`skills/zh-cn/`).

## Skills

### web-research — Stop answering from stale memory

**The problem.** Ask an AI "what's the best model right now?" and it answers from training-time knowledge — confidently missing things that shipped last month, and citing a "top list" that is already outdated.

**What it does.**
- Searches first, always — and stamps the current date in the conclusion
- Breaks the question into non-overlapping subtopics, then researches each
- Traces claims back to **primary sources** (official docs, release pages, APIs), not second-hand blog posts
- Checks community sentiment and adoption; cross-verifies across independent sources
- Delivers a recommendation with cited sources and explicit uncertainty

**How to use.** Just ask *"what's the best open-source image model in 2026?"* — it runs the research flow and answers with sources.

→ [English](skills/en/web-research/SKILL.md) ｜ [中文](skills/zh-cn/web-research/SKILL.md)

### file-notes — Make every output self-explanatory

**The problem.** Files and backups an agent creates make sense *at the time*, but weeks later (or in a new conversation) nobody knows what they are, why they exist, or how to restore them. A backup without notes becomes junk you dare not delete and cannot use.

**What it does.**
- Every backup ships with a `README.md`: what it is, where it came from, **why** it was made/removed, when, and how to restore
- Scripts, configs, and data/output files carry enough comments to be understood later
- Avoids over-commenting: temp files and self-explanatory names don't need essays

**How to use.** Automatic — whenever the agent backs up or generates files.

→ [English](skills/en/file-notes/SKILL.md) ｜ [中文](skills/zh-cn/file-notes/SKILL.md)

### install-check — Check before you install

**The problem.** The same tool gets installed twice — once per conversation — because the agent never checks what is already on the machine. Real example: a 7z extractor was downloaded twice while a full 7-Zip install already existed on another drive.

**What it does.**
- Before installing anything, check whether it is already present — **not just PATH**, also common install dirs and the registry
- Already installed → use it, never reinstall
- Not installed → look up the latest version (via `web-research`), pick a package manager, **confirm with the user**, then install
- Install to a predictable location so it can be found next time

**How to use.** Automatic — before any install/upgrade action.

→ [English](skills/en/install-check/SKILL.md) ｜ [中文](skills/zh-cn/install-check/SKILL.md)

## Structure

```
.
├── README.md                 ← this file
├── LICENSE                   ← MIT
└── skills/
    ├── en/                   ← English versions
    │   ├── web-research/
    │   │   └── SKILL.md
    │   ├── file-notes/
    │   │   └── SKILL.md
    │   └── install-check/
    │       └── SKILL.md
    └── zh-cn/                ← Chinese versions (成对的翻译)
        ├── web-research/
        │   └── SKILL.md
        ├── file-notes/
        │   └── SKILL.md
        └── install-check/
            └── SKILL.md
```

> English `SKILL.md` files are kept free of Chinese characters; the Chinese wording lives only in the matching `zh-cn/` copy.

## Installation

### Via skills CLI (installs the English version)

```bash
# list available skills
npx skills add mfx1433/skills --list

# install one
npx skills add mfx1433/skills --skill web-research
```

> The CLI resolves the English copies under `skills/en/`. For the Chinese version, use the manual copy below.

### Manually (clone and copy)

```bash
git clone https://github.com/mfx1433/skills.git
# pick the language you want, e.g. Chinese:
cp skills/zh-cn/web-research/SKILL.md ~/.agents/skills/web-research/SKILL.md
```

No restart needed — the agent's skill-directory watcher picks up new skills automatically.

## Skill format

Each skill is a folder containing a `SKILL.md` with YAML frontmatter:

```markdown
---
name: skill-name                       # required, kebab-case
description: "When to use it, what it does"   # required, drives triggering
---

# Body: the actual instructions
```

- `name` — identifier (lowercase, hyphens)
- `description` — **the most important field**: it decides *when* the agent invokes this skill

## License

MIT License — see [LICENSE](LICENSE). Free to use, modify, and distribute.

---
---

# Skills（中文）

> 自用的 Agent Skills 集合，基于开放的 [Agent Skills](https://skills.sh/) 生态。
> 作者：[@mfx1433](https://github.com/mfx1433) ｜ 许可：MIT
>
> **双语** —— 每个 skill 同时提供英文版和中文版，分别放在 `en/` 和 `zh-cn/` 目录下。

[English](#skills) | **中文**

---

## 这是什么

这里存放我写的 / 定制的 AI Agent skill。每个 skill 是一段**可复用的任务指令**——装上后，AI 在合适场景会自动按它执行。

这些 skill 不是为了加功能，而是为了修**我反复踩的坑**：凭旧记忆作答、留下看不懂的文件、同一个工具装两遍。

每个 skill 都提供**英文版**（`skills/en/`）和**中文版**（`skills/zh-cn/`）。

## 包含的 Skill

### web-research — 别再凭旧记忆瞎答

**痛点**：问 AI"现在哪个最好"，它凭训练时的旧知识回答——自信地漏掉上个月刚发布的东西，还引用一个早就过时的"最佳榜单"。

**它做什么**：
- 强制**先搜再答**，并在结论里标注当前日期
- 把问题拆成**互不重叠的子主题**，逐个调研
- 关键结论**追溯到一手来源**（官方文档、发布页、API），不轻信二手文章
- 查**社区口碑和采用度**，多个独立来源交叉核对
- 给出**带来源的推荐**，并明确标注不确定性

**怎么用**：直接问"2026 年最好用的开源生图模型是哪个？"——它会自动跑这套流程，并给出带来源的结论。

→ [英文](skills/en/web-research/SKILL.md) ｜ [中文](skills/zh-cn/web-research/SKILL.md)

### file-notes — 让每个产出都能看懂

**痛点**：AI 生成的文件、做的备份，**当时清楚，事后糊涂**。隔几周（或换个对话）就没人知道这是什么、为什么存在、怎么恢复。没有说明的备份，会变成"不敢删、也用不了"的垃圾。

**它做什么**：
- 每次备份都附带 `README.md`：是什么、原位置、**为什么**备份/删除、时间、怎么恢复
- 脚本、配置、数据/输出文件带足够的注释，事后能看懂
- 避免过度注释：临时文件、名字已自解释的不必长篇大论

**怎么用**：自动生效——AI 备份或产出文件时会按它执行。

→ [英文](skills/en/file-notes/SKILL.md) ｜ [中文](skills/zh-cn/file-notes/SKILL.md)

### install-check — 装之前先查

**痛点**：同一个工具被装了两遍——每个对话装一次——因为 AI 从不检查机器上是不是已经有了。真实例子：明明另一块盘上已经装了完整的 7-Zip，却还下载了两次 7z 解压工具。

**它做什么**：
- 装任何东西前，先查系统里是否已有——**不只查 PATH**，还查常见安装目录和注册表
- 已装 → 直接用，**绝不重装**
- 没装 → 查最新版（走 `web-research`）→ 选包管理器 → **经用户确认** → 再装
- 装到可预测的位置，方便下次找到

**怎么用**：自动生效——任何安装/升级操作之前。

→ [英文](skills/en/install-check/SKILL.md) ｜ [中文](skills/zh-cn/install-check/SKILL.md)

## 目录结构

```
.
├── README.md                 ← 本文件
├── LICENSE                   ← MIT 许可
└── skills/
    ├── en/                   ← 英文版
    │   ├── web-research/SKILL.md
    │   ├── file-notes/SKILL.md
    │   └── install-check/SKILL.md
    └── zh-cn/                ← 中文版（成对的翻译）
        ├── web-research/SKILL.md
        ├── file-notes/SKILL.md
        └── install-check/SKILL.md
```

> 英文版的 `SKILL.md` 保持不含中文字符；中文措辞只放在对应的 `zh-cn/` 版本里。

## 安装

### 用 skills CLI（装的是英文版）

```bash
# 列出可用的 skill
npx skills add mfx1433/skills --list

# 安装某一个
npx skills add mfx1433/skills --skill web-research
```

> CLI 解析到的是 `skills/en/` 下的英文版。要中文版，请用下面的手动复制方式。

### 手动（clone 后复制）

```bash
git clone https://github.com/mfx1433/skills.git
# 选你要的语言，例如中文：
cp skills/zh-cn/web-research/SKILL.md ~/.agents/skills/web-research/SKILL.md
```

安装后**无需重启**——AI 的 skill 目录监视器会自动检测到。

## Skill 格式说明

每个 skill 是一个目录，内含 `SKILL.md`，开头是 YAML frontmatter：

```markdown
---
name: skill-名字                       # 必填，kebab-case
description: "什么时候用、做什么"        # 必填，决定触发时机
---

# 正文：具体指令
```

- `name`：skill 标识（小写、连字符）
- `description`：**最重要**——它决定 AI 什么时候调用这个 skill

## 许可

MIT License，见 [LICENSE](LICENSE)。可自由使用、修改、分发。
