---
name: pr-reviewer
description: Analyze PR comments and failing checks, resolve comment threads, and debug/fix blocking check failures in a consolidated, efficient workflow.
license: MIT
metadata:
  author: ai-agent-setup
  version: "1.0"
---

# PR Reviewer Skill

Analyze and address PR comments and failing CI checks in a unified workflow to ensure a green, mergeable pull request. Use when you need to follow up on review feedback, handle CI test or compilation blockers, and cleanly resolve review threads.

## Input

- **PR Reference / ID**: The identifier, branch name, or URL of the target pull request.
- **Review Context**: Active comments, thread identifiers, and current CI check status runs.
- **Auto-Resolve Mode**: Specify whether residual threads should be resolved via GraphQL or MCP tools (defaults to true).

## Steps

1. **Gather PR Context & Review State**
   - Retrieve all active comment threads and current CI check runs for the pull request.
   - Detect the latest commit SHA and branch name to ensure modifications are performed on the correct HEAD.

2. **Analyze and Classify Comments**
   - Read every open comment thread on the PR.
   - For each comment, determine the appropriate action:
     - **Actionable Change**: The suggestion is valid and requires code modifications.
     - **Non-Issue / Clarification**: The suggestion is based on a misunderstanding, is out of scope, or represents a design decision that can be justified.

3. **Assess Failing Checks**
   - Compile all failed checks (including duplication, complexity, build stability, unit/integration tests, and general CI pipeline checks).
   - Inspect the check status/rules to determine if they are **blocking** the merge or are merely **informative** (non-blocking).
   - Focus exclusively on resolving the blocking failures. For each blocking check, analyze error logs, stack traces, and diagnostics to pinpoint the root cause.

4. **Consolidate and Execute Changes**
   - Identify all code changes required to address BOTH the actionable PR comments and the blocking check failures.
   - Plan and apply these code modifications together in a single, coordinated set of edits. Avoid split-up edits or multiple fragmented commits.
   - Prior to committing, verify changes locally (e.g. run build, unit tests, linting, format checks) to ensure the fixes resolve the problems without introducing regressions.

5. **Respond, Commit, and Push**
   - For comments that were deemed "non-issues," draft professional, polite replies explaining the rationale clearly.
   - Commit the consolidated fixes with a clear, descriptive message (e.g., `chore: resolve PR comments and fix CI build blockers`).
   - Push the commit to the remote PR branch.

6. **Wait & Resolve Residual Threads**
   - Wait exactly **45 seconds** after the push to allow webhooks, CI status sync, and platform automation to process the new commit.
   - Re-evaluate the PR status and active comment threads.
   - If any comment threads that were successfully addressed remain open (i.e. did not auto-resolve through the pushed changes), manually resolve them using MCP tool calls or GitHub GraphQL mutations.

## Guardrails

- **Polite & Constructive Communication**: Always reply to commentators with an encouraging, professional, and respectful tone. Ground justifications for "non-issues" in technical evidence or architectural patterns.
- **Do Not Fix Non-Blockers**: Do not spend time or edit code to satisfy non-blocking, purely informative checks unless explicitly requested.
- **Consolidated Commit Strategy**: Group both comment-driven edits and blocker-driven fixes into a single clean commit/push to minimize review overhead and avoid redundant CI runs.
- **Idempotency & Precision**: Ensure thread resolutions are only executed for comments that have actually been fully addressed. Avoid resolving threads prematurely.
