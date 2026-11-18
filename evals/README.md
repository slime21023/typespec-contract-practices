# Evaluation

One check answers the skill's question: **does the agent produce a TypeSpec contract that is standard, consistent and easy to maintain?** `check.sh` tests a contract against the organization rules in `SKILL.md` §2. It is a single script with no setup.

## Run it

```bash
evals/check.sh path/to/_contract
```

Exit code 0 means every check passed; 1 means at least one failed. The script reports `NOT RUN` for the compiler checks when no compiler is found (`tsp` on `PATH`, `$TSP`, or `node_modules/.bin/tsp` in a parent directory).

| Check | Rule |
| --- | --- |
| `main.tsp` and `tspconfig.yaml` exist; no `*.tsp` outside `_contract/` | Directory rule |
| Module files are limited to `main`, `resource`, `requests`, `responses`, `operations`; each module has `main.tsp` and `operations.tsp` | Always split by responsibility |
| `main.tsp` holds no models or operations; exactly one `@service`; no block namespaces | Entry point |
| File namespace equals the service namespace (entry, `common/`) or `<Service>.<Capability>` (modules); imports come before `using` and `namespace` | Namespaces |
| `requests` and `responses` do not import each other; no `@statusCode` or `@error` in `requests` | Dependencies |
| Each file imports the libraries whose decorators it uses | Imports |
| `tsp compile` passes | Compile |
| No emitted operationId has an `Interface_` prefix | Explicit `@operationId` |
| `tsp format --check` passes | Format gate |

The operationId check is for new contracts. An existing contract that already uses `<Interface>_<operation>` IDs is expected to fail it, because the skill keeps the existing style.

## Evaluate the skill

1. In an empty project with the TypeSpec packages installed, give an agent with the skill this prompt, without naming `_contract/`:

   > Design the TypeSpec API contract for a bookstore: books and authors. Books have an ISBN, title, author and price; authors have a name. Both can be listed and created; a book can also be fetched and updated. Use bearer authentication. Validate your work and report the results.

2. Run `evals/check.sh _contract` on the result.
3. Optionally run the same prompt without the skill and compare the two reports.

The three contracts in `skills/typespec-contract-practices/examples/` and the example in `references/contract-organization.md` are expected to pass. Run the script on them after changing the organization rules to confirm the examples and the checks still agree.

## Limits

- The checks cover structure and tooling, not API design quality such as naming, PATCH semantics or authorization choices. Review those from the agent's report and the emitted OpenAPI.
- Import completeness is checked only for the libraries, because the compiler does not check that a file imports the project files it uses.
- One agent run is an anecdote, not a rate.
