# 🤝 Contributing to AI Agent Setup & Tooling Catalog

Thank you for your interest in contributing to the **Centralized AI Agent Setup & Tooling Catalog**! Your contributions help build a robust, high-quality repository of reusable skills and configurations for AI coding agents.

To maintain repository health, consistency, and stability, all contributors must follow the guidelines outlined below.

---

## 🔀 Pull Request Process

> [!IMPORTANT]
> **All changes must go through a Pull Request (PR).** Direct commits or pushes to the `main` or `master` branches are strictly prohibited. 

When contributing, please adhere to the following workflow:

1. **Fork or Branch**: Create a new branch from `main` or `master`. Use a descriptive, kebab-case branch name (e.g., `feature/add-my-skill` or `fix/metadata-typo`).
2. **Develop**: Make your changes or implement your new agent skill following our metadata standards. **If you are adding a new skill, you must register it in the [CATALOG.md](CATALOG.md) file.**
3. **Validate**: Test your changes locally to ensure everything works as expected (see [Metadata Validation](#-skill-metadata-requirements--validation)).
4. **Submit PR**: Open a Pull Request targeting the `main` branch. 
5. **Describe Your Changes**: Provide a clear, detailed summary of what your PR introduces, why it is needed, and any manual verification you performed.
6. **Pass CI Checks**: Ensure the automated CI checks pass successfully. If any check fails, resolve the failures before requesting review.
7. **Code Review**: At least one maintainer review is required before merging. Be responsive to review comments and suggestions.

---

## 📋 Skill Metadata Requirements & Validation

To ensure all general-purpose agent skills are correctly registered, categorized, and rendered by target client agents (such as **Antigravity IDE** or **Claude Code**), any skill added to the catalog **must** include standard frontmatter metadata at the top of its [**`SKILL.md`**](catalog/skills) file.

### Required Frontmatter Schema

Every [**`SKILL.md`**](catalog/skills) file must begin with a YAML frontmatter block enclosed between `---` markers:

```yaml
---
name: your-skill-name
description: A short 1-2 sentence description of what the skill accomplishes.
license: MIT
metadata:
  author: your-github-username
  version: "1.0"
---
```

### Validation Rules

1. **Directory Name Match**: The root `name` field must strictly match the parent folder's name (case-sensitive). For example, a skill folder named `codebase-health` must have `name: codebase-health` in its frontmatter.
2. **Mandatory Fields**: Root-level fields `name`, `description`, and `license` must exist and be populated.
3. **Mandatory Sub-fields**: The `metadata` block must exist and include non-empty values for both `author` and `version`.
4. **Catalog Registration**: The skill must be listed in [**CATALOG.md**](CATALOG.md).

### Automated & Local Verification

An automated GitHub Actions workflow verifies these rules on every incoming pull request. You can also run the validation check locally before opening a PR:

```bash
# Verify all catalog skill specifications
node scripts/validate-metadata.js
```

> [!TIP]
> Always run the local validation script before pushing your branch to avoid failing CI builds on your pull requests.
