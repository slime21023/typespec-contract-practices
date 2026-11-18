# TypeSpec Contract Best Practices

An agent skill that helps AI coding agents create, review, refactor and validate **TypeSpec API contracts** (emitting OpenAPI 3) with consistent, verifiable practices.

Repository: [slime21023/typespec-contract-practices](https://github.com/slime21023/typespec-contract-practices)

## Core goals

1. **TypeSpec is the single source of truth.** Emitted OpenAPI is a generated artifact: never hand-edited, never treated as source.
2. **Contracts live in `_contract/`.** All project-owned `*.tsp` files and `tspconfig.yaml` stay under the project-root `_contract/`, not scattered across `src/`, `app/`, `docs/` or the repository root.
3. **Security and compatibility are not guessed.**
   - Roles, permissions, scopes and policy IDs are never invented; if they cannot be checked against the project's registry, the affected change is blocked.
   - OpenAPI extensions are descriptive metadata, not enforcement. Missing or invalid authorization metadata never grants access.
   - Relaxing authentication or authorization is a security regression: it needs explicit approval and is assessed separately from backward compatibility.
4. **Validation results are reported honestly.** A check that was not executed is reported as `NOT RUN` with the reason, never as `PASS`.
5. **No stack lock-in.** The skill follows the project's existing package manager, formatter and publishing pipeline, and does not impose a framework or new tooling.

## Contents

```text
skills/typespec-contract-practices/
  SKILL.md                          # agent workflow and hard rules (authoritative)
  references/
    contract-organization.md        # file layout, namespaces, operation IDs, with a complete example
    modeling-and-http.md            # naming, models, PATCH, HTTP, errors, syntax examples
    authorization.md                # authentication, authorization, x-authorization extension
    versioning-and-validation.md    # compatibility review, validation gates, completion check
  examples/                         # compilable sample contracts (illustrative, not a mandated architecture)
    basic-crud/  rbac-api/  versioned-api/
evals/                              # repeatable use-case tests for the skill (not installed)
```

## Installation

```bash
bunx skills add slime21023/typespec-contract-practices
```

Then start a new agent session. The agent loads the skill when a request involves TypeSpec contracts, `.tsp` files or OpenAPI output.

To install manually, copy `skills/typespec-contract-practices/` into your agent's skills directory.

## Compiling the examples (optional)

The skill itself has no runtime dependencies. To compile the examples yourself you need Node.js and compatible versions of `@typespec/compiler`, `@typespec/http`, `@typespec/openapi` and `@typespec/openapi3` (plus `@typespec/versioning` for `versioned-api`). Then run `tsp compile .` from the example's `_contract/` directory.

## Evaluation

`evals/` holds five use cases that compare agents with and without the skill, plus scripts to prepare and grade runs. See [evals/README.md](evals/README.md) for how to run them and [evals/results/](evals/results/) for recorded results.