---
name: readme-builder
description: Scan the codebase to build or refactor a highly professional, visually stunning, and interactive README.md featuring dynamic diagrams, clear installation workflows, and structured portals.
license: MIT
metadata:
  author: ai-agent-setup
  version: "1.0"
---

# README Builder Skill

Build or upgrade a repository's `README.md` to professional standards. Use when a project lacks documentation, when a new major version is launched, or to convert a simple text file into a premium development portal.

## Input

- **Project Root**: Target directory to inspect.
- **Tone & Style**: Desired tone (e.g. enterprise, highly developer-focused, casual/open-source).
- **Include Diagrams**: If set to true, generate dynamic visual structures (Mermaid charts).

## Steps

1. **Information Extraction**
   - Scan root files to identify:
     - Core technology stack (frameworks, runtimes, package managers, databases).
     - Entry points (e.g., `src/index.ts`, `app.py`, `Program.cs` for .NET, `src/main/java/.../Application.java` for Java).
     - Configuration parameters and environment variables (`.env.example`, `appsettings.json` for .NET, `application.properties`/`application.yml` for Java, `.config`).
     - Testing and deployment scripts in config files.
   - Scan main source folders to understand architecture, core capabilities, and data flows.

2. **Structure Design**
   - Design a premium Markdown template containing:
     - **Header**: Clean name, descriptive tagline, and badge placeholders.
     - **Portal/Table of Contents**: Quick links for fast navigation.
     - **Key Features**: Visually styled list of core capabilities with screenshots/diagram slots.
     - **Prerequisites**: Clear list of minimum requirements.
     - **Installation & Onboarding**: Clear, step-by-step commands (with both package manager and Docker options if available).
     - **Usage Guides**: Practical code snippets showing the project in action.
     - **Architecture & Design**: Clear textual explanation and visual Mermaid charts.
     - **Configuration Matrix**: A markdown table describing environment variables, defaults, and purposes.
     - **Contribution**: Clean steps on how to fork, open issues, and make pull requests.

3. **Generate Mermaid Diagrams**
   - Draft a structural or dataflow Mermaid diagram illustrating:
     - Core components (UI, Server, DB, external services).
     - Data flow directions during typical operations.
   - Use clean, quote-bounded node labels and modern layout configurations (e.g. top-down `TD` or left-to-right `LR`).

4. **Assemble & Apply Style Guidelines**
   - Compile the document using premium styling and formatting:
     - Harmonious emoji use (used as accents, never overwhelming text).
     - Clear list structures and short lines to prevent wrapping.
     - Syntactically highlighted code blocks with correct language identifiers.
     - Alert callouts (`> [!NOTE]`, `> [!IMPORTANT]`, etc.) to highlight critical onboarding steps.

5. **Review & Verify**
   - Verify that all relative markdown links work and all code snippets are valid syntactically.
   - Write the content to `README.md` (or output a draft for approval).

## Guardrails

- **Do Not Hallucinate**: Only document features and configurations that actually exist in the codebase. Do not list speculative plans or modules that are not implemented unless clearly marked under a "Future Roadmap" section.
- **Keep Existing Content**: If refactoring an existing README, preserve custom documentation, licensing notes, copyright, and author attributions.
- **Optimize for Scannability**: Use tables, bold accents, and lists to make the README easily parsed within 10 seconds of landing.
