# Versioning and validation details

## Compatibility review

- Compare with the published baseline; preserve the target OpenAPI version and operation IDs.
- Check required fields, enum values, response types, routes, status codes and authorization.
- Added enum members break exhaustive clients; added response properties can break strict consumers.
- Removing authentication or weakening a tenant policy is a security regression even when the change is compatible. Obtain approval for intentional relaxation.
- Use `@typespec/versioning` (`@versioned`, `@added`, and related decorators) for intentional evolution. The openapi3 emitter writes one file per version, such as `openapi.v1.yaml`. Inspect each one.
- Put every `import` before `using` statements and declarations; otherwise the compiler reports `import-first`.
- Moving a published model to another namespace renames its emitted schema (`Book` becomes `Books.Book`). The wire format is unchanged, but generated SDK types are renamed, so treat it as breaking.
- Splitting or merging files without changing namespaces leaves the emitted OpenAPI unchanged.
- Compatible alternatives (confirm each by compiling with the installed compiler):
  - Rename an enum member but keep its wire value: `awaiting: "pending"`.
  - Deprecate a property with the `#deprecated "reason"` directive, which emits `deprecated: true`. Do not write `@deprecated`; it is not a decorator.

## Validation gates

Inspect package versions and repository scripts before running commands; do not invent CLI options. A typical compile is `tsp compile .` from `_contract/`, after checking the installed CLI version.

Run in this order, skipping gates that do not apply:

1. Format check: `tsp format --check` on the files you created or changed. It ships with the compiler, so it applies even when no formatter is configured.
2. Compile
3. Lint (only if configured)
4. OpenAPI validation (only if tools exist)
5. Breaking-change comparison (only if a baseline exists)
6. Contract, integration and security tests (if runnable)

Format the files you create. If a file you edit was already unformatted before your change, report the format gate as FAIL with that reason instead of reformatting untouched code in the same change.

Report each gate as PASS, FAIL or NOT RUN, with the command and, for NOT RUN, the reason. Inspect emitted paths, schemas, status codes, security and extensions.

## Completion check

- All project-owned TypeSpec and TypeSpec config are under `_contract/`; no hand-edited generated output.
- Emitted OpenAPI matches the intended contract and target version.
- Security regressions are assessed; blockers are resolved or reported.
- The report lists modified files, behavior changes, validation results and remaining risks.
