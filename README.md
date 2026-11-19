# TypeSpec Contract Practices

An agent skill for creating, reviewing, refactoring, and validating TypeSpec API contracts and their generated OpenAPI 3 documents.

## Use

Install with the `skills` CLI:

```bash
bunx skills add slime21023/typespec-contract-practices
```

For manual installation, copy `skills/typespec-contract-practices/` into your agent's skills directory. Start a new session and ask the agent to apply `typespec-contract-practices` to your contract task.

[SKILL.md](skills/typespec-contract-practices/SKILL.md) defines the project-root `_contract/` layout, HTTP and PATCH semantics, authorization requirements, and comparison against a published OpenAPI baseline when available. The [TypeSpec references](skills/typespec-contract-practices/references/) illustrate contract organization, HTTP modeling, authorization metadata, and versioning.

## Validation

All four reference files compiled individually with TypeSpec compiler 1.18.0 and emitted five OpenAPI 3.0 documents. In one review exercise, Codex was given the skill text explicitly and identified all five seeded issues covering layout, operation IDs, PATCH nullability, permission verification, and authentication.

Automatic skill discovery, linting, published-baseline comparison, and runtime authorization were outside the scope of that exercise.
