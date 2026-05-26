# 🗂️ General-Purpose Skills Catalog

This catalog contains the comprehensive list of general-purpose agent skills available in this repository. These standalone skills are designed to be loaded by agents either centrally (user-wide) or locally (project-wide) to automate complex development workflows.

---

## 🛠️ Available Agent Skills

*   [**`codebase-health`**](catalog/skills/codebase-health/SKILL.md)
    *   **Description**: Instructs agents to perform a comprehensive codebase checkup (compiles/builds, executes tests, runs lints, validates formatting, checks for vulnerability alerts, and outputs a structured Markdown scorecard).
*   [**`test-generator`**](catalog/skills/test-generator/SKILL.md)
    *   **Description**: Guides agents in analyzing source modules to design comprehensive unit/integration test matrices covering positive paths, async/mock behaviors, and logical edge cases.
*   [**`readme-builder`**](catalog/skills/readme-builder/SKILL.md)
    *   **Description**: Directs agents in scanning a codebase and scaffolding or refactoring a gorgeous, interactive README featuring technical overviews, configuration matrices, and dynamic Mermaid diagrams.
*   [**`pr-reviewer`**](catalog/skills/pr-reviewer/SKILL.md)
    *   **Description**: Directs agents to review PR comment threads (responding or making changes), analyze and debug blocking CI/CD check failures (complexity, builds, tests), and coordinate resolutions in a unified commit-and-wait workflow.

---

## 📥 How to Install Skills

You can load these skills into your target client environments (such as Antigravity IDE or Claude Code) using our cross-platform installation scripts. For detailed installation instructions, please refer back to the [**README.md**](README.md).
