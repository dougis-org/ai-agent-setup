# Centralized Agent Tooling & MCP Setup Guide

This guide describes how to configure and run centralized Model Context Protocol (MCP) tooling and command-line proxies for your AI coding agents (such as **Antigravity IDE**, **Claude Code**, and **Claude Desktop**). 

The primary focuses are:
1. **TokenSave**: A local-first semantic indexer designed to dramatically reduce token costs and accelerate codebase comprehension.
2. **RTK (Rust Token Killer)**: A high-performance CLI proxy that intercepts terminal command outputs and compresses them by 60–90% before they reach the agent.

---

## 🚀 1. The TokenSave MCP Tooling

### What is TokenSave?
Traditional AI coding agents explore codebases by running broad file scans (`grep`, `glob`, or full-file reads). In larger repositories, this rapidly fills the LLM's context window, degrading performance and incurring massive API token costs.

**TokenSave** shifts the paradigm:
1. It parses your codebase locally using `tree-sitter` to extract structures (classes, methods, functions, and import/call dependencies).
2. It indexes these structures into a local SQLite graph database.
3. It exposes a specialized MCP server. Instead of reading full files, the agent queries the semantic graph directly (using tools like `tokensave_search`, `tokensave_context`, or `tokensave_impact`).

> [!TIP]
> Using TokenSave can reduce context bloat by up to **80%** in large codebases while providing the agent with perfect call-graph and dependency-impact information.

---

## 📥 2. Installing TokenSave

Since TokenSave is a native high-performance Rust binary, it does not require a Node runtime or heavy `node_modules` downloads.

### Option A: Cargo (All Platforms - Recommended)
If you have Rust/Cargo installed, run:
```bash
cargo install tokensave
```

### Option B: Windows (Scoop)
Add the custom bucket and install:
```powershell
scoop bucket add tokensave https://github.com/aovestdipaperino/scoop-bucket.git
scoop install tokensave
```

### Option C: macOS (Homebrew)
```bash
brew install aovestdipaperino/tap/tokensave
```

### Option D: Manual Download
Download the latest prebuilt binary from the [TokenSave Releases page](https://github.com/aovestdipaperino/tokensave/releases) and place it in your system `PATH`.

---

## ⚙️ 3. Project Indexing Setup

For each repository you want your agents to explore efficiently, you must initialize and build a semantic index:

```bash
# 1. Navigate to your project root
cd /path/to/your/project

# 2. Initialize TokenSave config (creates a local .tokensave/ config directory)
tokensave init

# 3. Build/update the semantic code graph
tokensave sync
```

> [!NOTE]
> It is highly recommended to run `tokensave sync` periodically or wire it up as a git post-commit hook to keep the semantic index perfectly up to date.

### Verify Installation
To confirm TokenSave is correctly installed in your system path and configured properly, run:
```bash
tokensave doctor
```

---

## 🔌 4. Configuring Central Agent Clients

Once the TokenSave binary is installed, register it centrally under your preferred agent interfaces.

### A. Antigravity IDE (Gemini)
To enable the TokenSave tools in the Antigravity IDE, update your central MCP configuration file.

* **Config File Location**: `C:\Users\doug\.gemini\antigravity-ide\mcp_config.json`
* **Configuration JSON**:
```json
{
  "mcpServers": {
    "tokensave": {
      "command": "tokensave",
      "args": ["mcp"],
      "env": {
        "PATH": "C:\\Users\\doug\\AppData\\Local\\Programs\\scoop\\shims;C:\\Users\\doug\\.cargo\\bin;C:\\Windows\\system32"
      }
    }
  }
}
```
*(Ensure the path environment variable includes the directory where the `tokensave` binary or shim resides).*

---

### B. Claude Code (CLI Agent)
Claude Code supports direct, automated hook registration:

```bash
# Run the native installer command for Claude
tokensave claude-install
```

This automatically:
- Adds the MCP configuration to `~/.claude.json`.
- Installs the "PreToolUse" hooks to capture exploration intents.
- Appends optimal query instructions to your `CLAUDE.md`.

For manual setup in `~/.claude.json`, add:
```json
{
  "mcpServers": {
    "tokensave": {
      "command": "tokensave",
      "args": ["mcp"]
    }
  }
}
```

---

### C. Claude Desktop (GUI Client)
Add the server entry to your desktop config:

* **Config File Location**: `%APPDATA%\Claude\claude_desktop_config.json` (Windows) or `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)
* **Configuration JSON**:
```json
{
  "mcpServers": {
    "tokensave": {
      "command": "tokensave",
      "args": ["mcp"]
    }
  }
}
```

---

## 🎯 5. Optimizing LLM Prompt Rules

To ensure your agents actually prefer TokenSave's query tools over expensive file-scanning tools, add the following rules block to your project's repository rules (e.g., `CLAUDE.md`, `GEMINI.md`, or system-prompt templates):

```markdown
# Repository Rules: Code Exploration and Token Optimization

> [!IMPORTANT]
> This codebase is semantically indexed using TokenSave. You MUST follow these rules to optimize token usage.

1. **Prefer TokenSave Tools**: Before running broad file scans (`grep`, `glob`, or reading full files to find references), ALWAYS attempt to query the code graph using `tokensave_search` or `tokensave_context`.
2. **Context Assembly**: Use `tokensave_context` to assemble related modules, structures, and implementations instead of opening multiple files.
3. **Impact Analysis**: When planning a refactoring, run `tokensave_impact` on target methods/classes to identify all upstream consumers that might be affected by the change.
4. **Fallback Mode**: Only fall back to standard file-grep or direct file-read operations if the TokenSave server is unavailable or you are looking for non-code assets (images, markdown documents, configurations).
```

---

## 🛠️ 6. Other Highly Recommended Centralized MCP Tooling

To build a fully centralized agent powerhouse, consider registering these additional standard MCP servers:

| MCP Server | Command | Purpose |
| ---------- | ------- | ------- |
| **SQLite** | `npx -y @modelcontextprotocol/server-sqlite` | Grants agents direct, read-only query access to local databases. |
| **Filesystem** | `npx -y @modelcontextprotocol/server-filesystem <allowed-paths>` | Lets agents safely access explicit folders outside the workspace tree. |
| **GitHub** | `npx -y @modelcontextprotocol/server-github` | Grants agents abilities to create issues, pull requests, and review comments. |

---

## ⚡ 7. The RTK (Rust Token Killer) Tooling

### What is RTK?
Traditional AI coding agents execute shell commands (`git status`, `ls`, `cargo test`, `npm run build`) to understand the environment and test results. These commands often return verbose, repetitive, or noisy terminal outputs that fill up the agent's context window and waste API tokens.

**RTK** acts as a lightweight command-line proxy:
1. It intercepts standard shell commands before the agent processes their output.
2. It strips out low-value noise, comments, whitespace, and repetitive log lines.
3. It aggregates similar items (e.g., grouping files or compiler warnings).
4. It presents compressed, high-signal information back to the agent, reducing token consumption by **60–90%**.

---

## 📥 8. Installing RTK

Since RTK is a high-performance Rust binary, install it directly onto your system.

> [!WARNING]
> **Avoid crates.io Direct Collision**: Do NOT run `cargo install rtk` directly. There is another package named `rtk` (Rust Type Kit) on crates.io. You must install the official tool using the `--git` flag or via Homebrew/Release binaries.

### Option A: Homebrew (macOS / Linux - Recommended)
```bash
brew install rtk
```

### Option B: Cargo (All Platforms with Rust Toolchain)
```bash
cargo install --git https://github.com/rtk-ai/rtk
```

### Option C: Quick Shell Script (Linux / macOS)
```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```
*(Ensure `~/.local/bin` is added to your system `PATH` if not already present).*

### Option D: Windows Manual Install
1. Go to the [RTK Releases page](https://github.com/rtk-ai/rtk/releases).
2. Download the appropriate `.zip` package for Windows.
3. Extract `rtk.exe` and place it in a folder included in your system `PATH` (e.g., your Scoop shims or a dedicated tools directory).

---

## ⚙️ 9. RTK Setup & Agent Initialization

Once installed, configure RTK to automatically hook into your agent's shell environment.

### Global Agent Integration
RTK can automatically intercept commands run by tools like Claude Code and Gemini/Antigravity shell environments. Enable global hooks:

```bash
# Initialize global shell hooks for standard agents (e.g., Claude Code, Copilot)
rtk init -g

# Or specifically enable Gemini / Antigravity support
rtk init -g --gemini
```

### Verifying Setup & Tracking Gains
Verify that RTK is properly working:
```bash
# Check version
rtk --version

# View accumulated token savings stats
rtk gain
```

Once initialized, standard shell commands run by your agent will automatically and transparently flow through RTK, saving your tokens without requiring any prefix commands!
