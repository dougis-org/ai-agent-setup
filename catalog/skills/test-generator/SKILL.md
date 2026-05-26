---
name: test-generator
description: Analyze source code files or functions to generate comprehensive, robust unit and integration tests covering positive paths, edge cases, and error conditions.
license: MIT
metadata:
  author: ai-agent-setup
  version: "1.0"
---

# Test Generator Skill

Generate high-quality, comprehensive tests for target functions, classes, or modules. Use when you need to increase code coverage, ensure safety during refactoring, or adopt TDD/BDD testing patterns.

## Input

- **Target File / Symbol**: Path to the source file and optionally the specific class or function name to target.
- **Framework**: The desired test framework (e.g. Jest, Vitest, PyTest, JUnit, RSpec). If omitted, automatically infer from project configurations.
- **Coverage Goal**: Target statement, branch, or function coverage.

## Steps

1. **Analyze Target Code and Existing Tests**
   - Read the target source file carefully.
   - Search the codebase for existing test support functions, mock helpers, custom utilities, or shared fixtures that should be reused to avoid duplicating tooling.
   - Map all logical branches, conditional statements (`if`, `switch`, loops), async operations, and error paths.
   - Detect external dependencies (e.g. database connections, API clients, file system access) that must be mocked or stubbed.

2. **Establish Mocking, Setup & Scaffolding**
   - Scaffold the test file using naming conventions matching the project structure (e.g., `foo.test.ts`, `test_foo.py`).
   - Import target files, test frameworks, mocking libraries, and any identified test helpers/utilities.
   - Configure clean setup/teardown handlers (`beforeEach`, `afterEach`) to isolate test executions, reusing the existing test setup and fixtures established for other tests.
   - Implement mocks/stubs for external dependencies to avoid side-effects, using standard shared mock helpers where applicable.

3. **Formulate Test Matrix**
   - Design a detailed set of test cases spanning:
     - **Happy Paths**: Typical inputs yielding successful, expected outcomes.
     - **Edge Cases**: Null, undefined, empty strings, zero, extremely large numbers, boundary index values.
     - **Error Handling**: Inputs meant to trigger exceptions, rejections, or validation failures.
     - **Asynchronous/Concurrent Cases**: Confirm promises, callbacks, and streams resolve correctly under delay.

4. **Write and Scaffold Test Code**
   - Write cleanly formatted test code using the project's standard assertion styles (e.g. `expect(res).toBe(...)` or `self.assertEqual(...)`).
   - Group related test cases using semantic test-suites (`describe` blocks).
   - Ensure all mock declarations are cleanly documented and simple to maintain.

5. **Execute and Refine**
   - Run the newly generated test file using the project's native test runner.
   - If tests fail:
     - Check if the failure is due to a bug in the *test* (e.g., incorrect mock setup, bad assertions) or a bug in the *source code*.
     - Correct the test code iteratively.
     - Run the tests again and confirm they pass completely.
   - Report code coverage results for the target file before completing.

## Guardrails

- **Zero Side-Effects**: Mock all network calls, database queries, and filesystem writes. Tests must run completely offline and leave no state behind.
- **Style Alignment**: Align with the project's existing testing styles, formatting, and indentation standards.
- **Never Over-mock**: Only mock outer dependencies. Avoid mocking internal logic of the module under test, as this renders the tests shallow and brittle.
- **No Duplicate Tooling**: Always prioritize reusing existing test support functions, setups, factories, or utilities over writing new ones. Avoid creating duplicate mocking or scaffolding layers.

