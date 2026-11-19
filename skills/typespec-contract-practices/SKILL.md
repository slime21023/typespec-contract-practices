---
name: typespec-contract-practices
description: Create, review, refactor and validate TypeSpec (.tsp) API contracts and their OpenAPI output. To Build the maintainable Typespec definitions for the OpenAPI3.
---

# TypeSpec Contract Practices

## Requirements

<Principles>
    TypeSpec is the definitions for API-first Development.
    Keep business and implementation code out of the contract unless integration work is requested.
    MUST live under the project-root `_contract/`. Never create TypeSpec in `src/`, `app/`, `docs/` or the repository root.
</Principles>

<FileStructures>
    _contract/
        main.tsp              # only entrypoint
        tspconfig.yaml
        common/
          auth.tsp       # shared auth shape
          errors.tsp     # shared error shape; common/ holds only what 2+ modules use
        modules/<capability>/ # the group of resources in the domain
          main.tsp            # imports the module's files
          resource.tsp        # resource model
          requests.tsp        # client input: bodies, parameters
          responses.tsp       # server output: status codes, pages, module errors
        generated/            # compiler output
</FileStructures>

<Rules>
    - Namespaces (MUST): Declare exactly one file-level `namespace X;` after imports; never use block namespaces (`namespace X { ... }`). Define a single `@service` on the root PascalCase namespace (`Bookstore`) used in `main.tsp` and `common/`. Map module directories to `<Service>.<Capability>` (`order-items` → `Bookstore.OrderItems`). Reference parent-namespace types directly, and cross-module types by fully qualified name (`Bookstore.Authors.Author`).
    - Breaking Changes (MUST): Preserve published field wire names, operation IDs, routes, and enum wire values unless making a deliberate, approved breaking change.
    - Field Presence & PATCH (MUST): Strictly distinguish required (`T`), omittable (`?: T`), nullable (`T | null`), and omittable-nullable (`?: T | null`) fields. In `PATCH` requests, treat omitted fields as unchanged and clear values on `null` only when the field explicitly allows `null`.
    - Models & Security (MUST / MUST NOT): Use precise scalar wire types, explicit validation constraints (`@minLength`, `@pattern`, etc.), and purpose-specific request/response models. Never expose secrets or internal administrative state.
    - Routing & HTTP (MUST): Design resource-oriented routes and apply explicit `@route` and HTTP verb decorators wherever path or method mapping could be ambiguous.
    - Errors & Access Control (MUST): Distinguish `401 Unauthorized` (unauthenticated) from `403 Forbidden` (unauthorized) without leaking the existence of sensitive resources. Model all error responses using the project's shared machine-readable `@error` shape.
    - Pagination & Mutations (MUST): Enforce one consistent pagination convention per API family. Document idempotency keys and concurrency preconditions (`If-Match`) for all nontrivial mutations.
    - Response Envelopes (MUST NOT): Never wrap 2xx responses in an artificial `{ code, message, data }` envelope unless explicitly required by the project.
    - Operation Documentation (MUST): Give every operation a meaningful OpenAPI description using `@doc` or a TypeSpec doc comment. Explain the behavior callers need to know, such as resource visibility, authorization conditions, side effects, preconditions, or relevant error conditions. Use `@summary` for a short title when useful. Avoid boilerplate that merely repeats the title or operation name.
    - Operation Tags (MUST): Give every operation at least one OpenAPI tag using `@tag`. Reuse the project's established tag names. Apply the tag to the capability namespace or interface when its operations share a group. Apply it to individual operations when grouping varies within the module.
</Rules>

<Auth>
    - Separation of Concerns (MUST): Strictly separate **authentication** (caller identity; security schemes, `@useAuth`), **scopes** (token capabilities), **roles** (IAM group memberships), **permissions** (business actions like `users:delete`), and **resource policies** (tenant, ownership, state).
    - Default-Deny Coverage (MUST): Explicitly mark every operation as authenticated or intentionally public per project convention, defaulting to deny when uncertain. If no auth convention exists, do not invent one—flag new operations as unauthenticated and ask.
    - Explicit Authorization (MUST / SHOULD): Define explicit permissions or resource policies for sensitive endpoints; never infer access rules from HTTP verbs. Prefer fine-grained permissions over enumerating roles.
    - Custom Decorators (MUST NOT): `@roles`, `@permissions`, and `@requirePermissions` are not built-in TypeSpec decorators; use them only if the project explicitly implements them.
    - Identifier Verification (MUST): Never invent roles, permissions, scopes, or policy IDs. Verify all identifiers against the project's registry and block changes if any cannot be verified.
    - Fail-Closed Enforcement (MUST): Treat OpenAPI extensions as descriptive metadata, never runtime enforcement. Missing, malformed, or conflicting metadata must fail closed and never grant access. Enforce authorization in the server, gateway, or policy engine, and add negative tests where runnable.
    - Logical Semantics & Schema (MUST): Make `AND`/`OR` evaluation semantics explicit. Preserve the project's existing extension schema, or use the reference schema for new projects.
</Auth>

<Versioning>
    - Baseline Comparison (MUST): Diff changes against the published OpenAPI baseline when available, not solely against TypeSpec source files.
    - Breaking & Policy Surface Detection (MUST): Flag any modifications to routes, HTTP methods, operation IDs, required inputs, response fields or types, enum wire values, status codes, scopes, permissions, roles, and resource policies.
    - API Evolution & Versioning (SHOULD / MUST): Favor additive changes and `@typespec/versioning` for intentional API evolution. Require an explicit version, deprecation, and migration strategy for breaking changes—noting that new enum members and added response properties can still break strict clients.
    - Explicit Breaking Requests (MUST): Execute breaking changes directly when explicitly requested; never silently substitute a compatible alternative. For each breaking item, report affected consumers and propose a compatible, versioned, or deprecation path. Ask for confirmation first only if the request is ambiguous or weakens security.
    - Downstream Compatibility (MUST): Preserve the target OpenAPI specification version and compatibility with downstream gateways, SDK generators, and validators.
    - Independent Security Regression Review (MUST): Audit security regressions separately from wire compatibility—flag removed authentication, relaxed scopes/roles/permissions, weakened resource policies, and newly exposed data. Any intentional security relaxation requires explicit approval, and note that tightening authorization can itself be a breaking change.
</Versioning>


## Linting and Validation

Use the target project's package manager and lockfile. Install TypeSpec and
Spectral in the target project when their respective checks are needed.

### TypeSpec source

For a Node.js project, install compatible versions of `@typespec/compiler`,
`@typespec/http`, `@typespec/openapi`, and `@typespec/openapi3`. Compile
`_contract/` with the project's local TypeSpec CLI.

Keep existing TypeSpec lint rules when their packages are installed and
compatible with the project's compiler. Add a `linter` section for a new project
after verifying the packages and rule IDs.

If the project requires named unions, check declarations in the `.tsp` source.
Use a compatible TypeSpec linter when available. Otherwise, record the manual
review and report the automated rule as `NOT RUN` with the reason.

Example `_contract/tspconfig.yaml`:

```yaml
emit:
  - "@typespec/openapi3"

options:
  "@typespec/openapi3":
    emitter-output-dir: "{project-root}/generated/openapi"
    output-file: "openapi.yaml"
```

### Generated OpenAPI

Install `@stoplight/spectral-cli` as a project development dependency. Use the
project's existing Spectral ruleset, or start with `_contract/.spectral.yaml`:

```yaml
extends: [spectral:oas]
```

Disable `oas3-api-servers` only when deployment supplies server URLs. Disable
`info-contact` only when project policy permits omitting contact information.
Document the reason next to each override.

For npm projects, run from the project root:

```bash
npx tsp compile _contract
npx spectral lint --ruleset _contract/.spectral.yaml _contract/generated/openapi/openapi.yaml
```

Run Spectral after successful compilation and lint each emitted OpenAPI
document. Report compilation and OpenAPI lint separately, include any lint
warnings, and mark checks that could not run as `NOT RUN` with the reason.

Verify that every emitted operation has a meaningful `description` and
at least one `tags` entry. When Spectral reports `operation-description`
or `operation-tags`, fix the corresponding TypeSpec source and regenerate
the OpenAPI document. Review descriptions for accuracy, since Spectral
checks presence and cannot verify that the text matches contract behavior.

## References

- Creating or reorganizing contract files, namespaces, operation IDs: `references/contract-organization.tsp`
- Models, DTOs, PATCH, HTTP, errors, syntax examples: `references/modeling-and-http.tsp`
- Authentication, permissions, policies, extensions: `references/authorization.tsp`
- Published API changes, validation, completion check: `references/versioning-and-validation.tsp`
