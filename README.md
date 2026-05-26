# 🤖 Centralized AI Agent Setup & Tooling Catalog

Welcome to the centralized portal for managing, installing, and configuring development tools and reusable skills for your AI coding agents (such as **Antigravity IDE**, **Claude Code**, and **Claude Desktop**).

This repository serves as an offline-first inventory of general-purpose agent capabilities, deployment scripts, and centralized Model Context Protocol (MCP) tooling guides.

---

## 📂 Repository Contents

| Path | Description |
| ---- | ----------- |
| [**`catalog/skills/`**](file:///c:/dev/ai-agent-setup/catalog/skills) | Reusable general-purpose agent skills (schemas/instructions). |
| [**`docs/tooling-setup.md`**](file:///c:/dev/ai-agent-setup/docs/tooling-setup.md) | Guide for setting up central MCP tools, highlighting **Tokensave MCP**. |
| [**`scripts/`**](file:///c:/dev/ai-agent-setup/scripts) | Cross-platform interactive installer scripts (`install-skill.ps1` / `install-skill.sh`). |

---

## 🛠️ 1. General-Purpose Skills Catalog

Standalone skills designed to be loaded by agents either centrally (user-wide) or locally (project-wide):

*   [**`codebase-health`**](file:///c:/dev/ai-agent-setup/catalog/skills/codebase-health/SKILL.md): Instructs agents to perform a comprehensive codebase checkup (compiles/builds, executes tests, runs lints, validates formatting, checks for vulnerability alerts, and outputs a structured Markdown scorecard).
*   [**`test-generator`**](file:///c:/dev/ai-agent-setup/catalog/skills/test-generator/SKILL.md): Guides agents in analyzing source modules to design comprehensive unit/integration test matrices covering positive paths, async/mock behaviors, and logical edge cases.
*   [**`readme-builder`**](file:///c:/dev/ai-agent-setup/catalog/skills/readme-builder/SKILL.md): Directs agents in scanning a codebase and scaffolding or refactoring a gorgeous, interactive README featuring technical overviews, configuration matrices, and dynamic Mermaid diagrams.

---

## 📥 2. Installer Scripts

We provide two resilient, cross-platform installers to load catalog skills into your development environment. They support:
- **Local installation**: Linking or copying skills directly to your downstream project's active agent surfaces (`.gemini/`, `.claude/`, `.codex/`, `.github/`).
- **Central installation**: Deploying skills globally to your user profile so they are active across all repositories.

### PowerShell (Windows)
To run the interactive installer in Windows:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-skill.ps1
```

Or pass direct CLI arguments:
```powershell
# Install codebase-health skill centrally to your user profile
powershell -File .\scripts\install-skill.ps1 -SkillName codebase-health -Target central

# Copy test-generator skill locally into a target repository path
powershell -File .\scripts\install-skill.ps1 -SkillName test-generator -Target local -Path C:\dev\my-target-project --Copy
```

### Bash (macOS / Linux / Git Bash)
To run the interactive installer in Bash:
```bash
sh scripts/install-skill.sh
```

Or pass direct CLI arguments:
```bash
# Install codebase-health skill centrally
sh scripts/install-skill.sh --skill codebase-health --target central

# Link test-generator skill locally in a target repository path
sh scripts/install-skill.sh --skill test-generator --target local --path /path/to/my-target-project
```

> [!TIP]
> **Windows Privilege Resilience**: If symlink or junction creation fails due to local Windows security restrictions or lack of Developer Mode, both scripts will catch the error and automatically fall back to Copy Mode.

---

## ⚡ 3. Centralized Tooling: TokenSave MCP

To optimize your AI coding agent's context window usage and cut API token costs, configure the **TokenSave MCP server**. TokenSave indexes class inheritance, call graphs, imports, and methods into a local SQLite database, allowing agents to query semantic graphs instead of executing expensive whole-file reads.

*   **Setup Guide**: Follow the step-by-step instructions in the [**tooling-setup.md**](file:///c:/dev/ai-agent-setup/docs/tooling-setup.md) guide to install the native TokenSave binary, pre-index your repositories, and register it centrally in your Antigravity, Claude, or Claude Desktop environments.

---

## 📜 4. OpenSpec Spec-Driven Workflows (Reference)

For projects using spec-driven development workflows, the source of truth for all OpenSpec-specific skills and templates is the **`openspec-shared`** repository.

*   **Submodule Reference**: Please refer directly to the [**`openspec-shared` README**](file:///c:/dev/openspec-shared/README.md) (or their [GitHub repository](https://github.com/dougis-org/openspec-shared)) for the definitive guide on adding `openspec-shared` as a submodule to your project and running its custom `bootstrap.sh` script to wire up spec proposal, exploration, code review, and archiving workflows.
