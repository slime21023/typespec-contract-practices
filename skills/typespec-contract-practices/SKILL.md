---
name: typespec-contract-practices
description: Create, review, refactor and validate TypeSpec (.tsp) API contracts and their OpenAPI output. All TypeSpec lives under the project-root `_contract/`.
---

# TypeSpec Contract Practices

TypeSpec is the source of truth; emitted OpenAPI is a generated artifact. Keep business and implementation code out of the contract unless integration work is requested. **MUST** = mandatory, **SHOULD** = default with justified exceptions, **MAY** = optional.

**Directory rule:** project-owned `*.tsp`, entrypoints and `tspconfig.yaml` MUST live under the project-root `_contract/`. Never create TypeSpec in `src/`, `app/`, `docs/` or the repository root. Emit OpenAPI to `_contract/generated/` unless an established publishing pipeline says otherwise. App-side generated clients and installed third-party dependencies may stay outside.

## 1. Activation

1. Identify the project root; locate `_contract/`, package manager, lockfiles, `tspconfig.yaml`, `.tsp` entrypoints, scripts and CI.
2. If TypeSpec exists outside `_contract/`, do not add to it, and do not move or delete it. Build the requested change in `_contract/`, copying the definitions it needs and leaving the originals untouched. Report the migration plan (what moves, entrypoint, `tspconfig.yaml`, output directory, import paths) for the user's decision. Report blocking conflicts; never move unrelated files or migrate destructively without a decision.
3. Inspect a comparable operation/model, published OpenAPI, error shape, auth convention, versioning strategy and target OpenAPI version (3.0 or 3.1). Keep established conventions that do not conflict with the directory rule.
4. Read `_contract/tspconfig.yaml`, scripts and installed versions before running any compiler command (MUST). Do not invent decorators, flags, policies or identifiers, and do not guess version-sensitive syntax.
5. If `_contract/` is missing, create it with the entrypoint and config, using the repository's existing dependency management.

**Blocking conditions.** Stop the affected changes when project root or contract ownership is ambiguous, authorization identifiers or policy semantics cannot be verified, a destructive migration needs an unresolved decision, or the request conflicts with established security or compatibility requirements. Continue independent work; report blockers and ask only for decisions needed to proceed.

## 2. Layout

```text
<project-root>/
  _contract/
    main.tsp            # entrypoint
    tspconfig.yaml
    common/             # errors, pagination, shared types
    security/           # authentication, authorization
    modules/<capability>/models.tsp, operations.tsp
    generated/          # compiler output only
```

- Keep a discoverable entrypoint and resolvable imports inside `_contract/`.
- Organize by business capability, not HTTP verb or controller. Centralize only genuinely shared primitives; avoid giant base models.
- Small projects may use a few files directly under `_contract/`; the tree is not mandatory.
- Do not restructure unrelated application code or introduce a framework. Never create or edit files in `generated/` by hand.

## 3. Contract conventions

Details: `references/modeling-and-http.md`.

- Preserve published field names, operation IDs, routes and enum wire values unless the change is deliberate (MUST).
- Distinguish required, omittable, nullable and omittable-nullable fields, and define PATCH semantics: omitted means unchanged; `null` clears only when explicitly supported (MUST).
- Use precise wire types and constraints, purpose-specific request/response models, and never expose secrets or internal administrative state.
- Use resource-oriented routes and explicit HTTP decorators where ambiguity matters.
- Distinguish 401 from 403 without disclosing sensitive existence details. Model errors with the project's shared machine-readable shape.
- Use one pagination convention per API family; document idempotency and preconditions for nontrivial mutations.
- Do not force a success envelope (`code/message/data`) without a project requirement (MUST NOT).
- Document non-obvious semantics, authorization conditions, side effects and errors; no comments that restate names.

## 4. Authentication and authorization

Details: `references/authorization.md`.

Keep these separate: **authentication** (caller identity; security schemes, `@useAuth`), **scopes** (token capabilities), **roles** (group memberships, mapped to permissions by IAM), **permissions** (business operations such as `users:delete`), **resource policies** (tenant, ownership, state).

- Mark each operation authenticated or intentionally public per project convention; default to deny when uncertain.
- Define permissions/policies for sensitive endpoints; never infer them from the HTTP verb. Prefer permissions over enumerating roles.
- `@roles`, `@permissions` and `@requirePermissions` are not built in; use them only if the project implements them.
- Never invent roles, permissions, scopes or policy IDs. Verify identifiers against the project's registry and block affected changes if they cannot be verified (MUST).
- OpenAPI extensions are descriptive metadata, never enforcement. Missing, malformed or conflicting metadata never grants access; invalid requirements fail closed (MUST). The server, gateway or policy engine enforces; add negative tests where runnable.
- Make AND/OR semantics explicit. Preserve the project's extension schema; the reference defines one for new projects.

## 5. Versioning and compatibility

Details: `references/versioning-and-validation.md`.

- Compare with the published baseline when available, not only the source.
- Flag changes to routes, methods, operation IDs, required inputs, response fields/types, enum wire values, status codes, scopes, permissions, roles and resource policies.
- Prefer additive changes and `@typespec/versioning` for intentional evolution; breaking changes need a version, deprecation and migration strategy. New enum members and added response properties are not unconditionally non-breaking.
- When the user explicitly asks for a breaking change, make the change as requested; never silently substitute a compatible design. For each breaking item, report who it breaks and offer a compatible, versioned or deprecation alternative. Ask first only when the request is ambiguous or relaxes security.
- Preserve the target OpenAPI version and downstream gateway/SDK/validator compatibility.
- Assess security regressions independently of compatibility: authentication removed, permission/role/scope relaxed, resource policy weakened, data newly exposed. Intentional relaxation needs explicit approval (MUST). Tightening authorization can itself be breaking.

## 6. Emit and validation

- Generate OpenAPI from `_contract/`; hand-patching generated output is never the lasting source of truth (MUST NOT).
- Check the impacted emitted paths/methods, parameters, requestBody, responses, operationId, schemas, security and extensions.
- Run available gates in this order, adapting to repository scripts: format check, compile, configured lint, OpenAPI validation, baseline comparison, contract/integration/security tests.
- Report any gate that was not executed as `NOT RUN` with the reason, and never as `PASS` (MUST). Without validation tooling the contract is not verified.
- Do not add CLI tools, GitHub Actions or custom emitters without user need and compatibility review.

## 7. Work procedure

1. **Inspect**: root, `_contract/`, comparable code, scripts, emitter, auth policy, baseline.
2. **Assess**: affected operations, schema, security and compatibility; list missing identifiers instead of guessing.
3. **Edit**: minimal, localized changes; TypeSpec only inside `_contract/`; touch application code or tests only if the task requires it.
4. **Generate and inspect** the emitted OpenAPI.
5. **Validate** with the available gates, including negative authorization tests.
6. **Report**:

```text
Summary
Files changed
Contract impact (endpoints, models, security, compatibility)
Validation (PASS / FAIL / NOT RUN, with commands or reasons)
Risks / assumptions / migration notes
```

Review-only requests: do not modify files (MUST NOT); give findings by severity with file locations. Reorganizing requests: preserve behavior and report changed imports and build paths.

## References

Read only what the task needs; this file is authoritative. `examples/` holds illustrative patterns, not mandatory architecture.

- Models, DTOs, PATCH, HTTP, errors: `references/modeling-and-http.md`
- Authentication, permissions, policies, extensions: `references/authorization.md`
- Published API changes, validation, completion check: `references/versioning-and-validation.md`
