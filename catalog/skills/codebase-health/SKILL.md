---
name: codebase-health
description: Diagnose the comprehensive health of a codebase by executing builds, runs, tests, linters, formatters, and analyzing dependency structures.
license: MIT
metadata:
  author: ai-agent-setup
  version: "1.0"
---

# Codebase Health Check

Diagnose the health of a codebase by verifying building, testing, linting, formatting, and analyzing dependency structures. Use when you want to establish a baseline before making changes or to ensure everything remains green afterward.

## Input

- **Target Directory**: The directory to analyze (defaults to current working directory).
- **Run Modes**: Specify if any checks should be skipped (e.g. `--skip-tests` or `--skip-lint`).

## Steps

1. **Environment Detection**
   - Automatically determine the project type by scanning the root files (e.g., `package.json` for Node, `requirements.txt`/`pyproject.toml` for Python, `pom.xml`/`build.gradle` for Java, `.csproj`/`.sln` for .NET, `Cargo.toml` for Rust, `Gemfile` for Ruby, etc.).
   - Announce the detected project type and active package managers (e.g. npm, poetry, maven, gradle, dotnet, cargo).

2. **Verify Build Stability**
   - Execute the native build or compilation command (e.g., `npm run build`, `mvn clean compile`/`gradle build`, `dotnet build`, `cargo build`, etc.).
   - Parse error logs to identify compilation warnings or broken dependency references.
   - If the build fails, compile a clean diagnostics table pointing to the exact broken files and line numbers.

3. **Run Test Suites**
   - Run the codebase's existing unit, integration, and end-to-end tests (e.g., `npm test`, `pytest`, `mvn test`/`gradle test`, `dotnet test`, `cargo test`).
   - If tests fail, list all failed test suites, specific assertions that broke, and the stack traces.
   - Summarize test coverage if the tool reports it.

4. **Verify Style, Linting, & Formatting**
   - Run linter commands (e.g., `eslint`, `flake8`, Checkstyle/SpotBugs for Java, `dotnet format --verify-no-changes` or Roslyn analyzers for .NET, `clippy`) and formatter dry-runs (e.g., `prettier --check`, `black --check`).
   - Identify formatting inconsistencies and code quality violations.
   - Highlight any potential bug patterns flagged by the linter (e.g. unused imports, shadow variables, unhandled promises).

5. **Structural & Dependency Analysis**
   - Locate circular dependencies in imports.
   - Search for obvious dead code (unused files, completely unreferenced methods/classes).
   - Check if there are known security vulnerabilities in package dependencies (e.g. `npm audit`, `dependency-check` for Java, `dotnet list package --vulnerable` for .NET, `cargo audit`).

6. **Generate Health Scorecard**
   - Output a beautiful, structured Markdown scorecard outlining:
     - **Build Status**: Green / Red (with build time)
     - **Tests**: Pass rate (e.g., `42 / 45 passed, 93%`), failed list
     - **Linting**: Count of warnings/errors
     - **Formatting**: List of files violating standards
     - **Vulnerabilities**: Count of high/medium issues found
     - **Key Recommendations**: A bulleted list of 3-5 high-priority actions to improve codebase health.

## Guardrails

- **Never write modifications**: This skill is purely diagnostic. Do not run auto-fix flags (`--fix`, `black .`, etc.) unless the user explicitly requests it.
- **Isolate environment**: Ensure build/test commands are executed within proper scopes so they do not write unversioned files or junk outside target builds.
- **Fail gracefully**: If a command is missing (e.g. no linter configured), do not error out; note the missing tool in the scorecard and proceed to the next step.
