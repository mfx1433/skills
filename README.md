# Skills

> 自用的 Agent Skills 集合，基于开放的 [Agent Skills](https://skills.sh/) 生态。
> 作者：[@mfx1433](https://github.com/mfx1433) ｜ 许可：MIT

## 这是什么

这里存放我写的 / 定制的 AI Agent skill。每个 skill 是一段**可复用的任务指令**，装上后 AI 在合适场景会自动按它执行。

## 包含的 Skill

| Skill | 用途 | 触发场景 |
|-------|------|---------|
| **web-research** | 高级联网调研方法论 | 问"哪个最好/最新/主流/推荐"、需要联网查证判断时 |
| **file-notes** | 文件注释与备份说明规范 | 备份文件、产出脚本/配置/数据等需事后能看懂的文件时 |

## 安装

用 [skills CLI](https://skills.sh/) 一键安装：

```bash
# 装全部 skill
npx skills add mfx1433/skills --all

# 只装某一个
npx skills add mfx1433/skills --skill web-research
npx skills add mfx1433/skills --skill file-notes

# 装到全局（用户级，所有项目可用）
npx skills add mfx1433/skills --skill web-research -g -y
```

安装后无需重启，AI 的 skill 目录监视器会自动检测到。

## 目录结构

```
.
├── README.md                  ← 本文件
├── LICENSE                    ← MIT 许可
└── skills/
    ├── web-research/
    │   └── SKILL.md           ← 联网调研方法论
    └── file-notes/
        └── SKILL.md           ← 文件注释/备份规范
```

## Skill 格式说明

每个 skill 是一个目录，内含 `SKILL.md`，开头是 YAML frontmatter：

```markdown
---
name: skill-名字          # 必填，kebab-case
description: "什么时候用、做什么"   # 必填，决定触发时机
---

# 正文：具体指令
```

- `name`：skill 标识（小写、连字符）
- `description`：**最重要**——它决定 AI 什么时候调用这个 skill

## 许可

MIT License，见 [LICENSE](LICENSE)。可自由使用、修改、分发。
