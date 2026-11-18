# Skill evals

Repeatable use-case tests for the `typespec-contract-practices` skill. Each case is a small project seed plus the user request given to an agent. A run with the skill installed (`skill`) is compared with a run without it (`base`).

This folder is not part of the installed skill; `bunx skills add` only copies `skills/typespec-contract-practices/`.

## Cases

| Case | Request | What it tests |
| --- | --- | --- |
| `uc1-bookstore` | Create a bookstore contract from scratch | Layout, money, constraints, pagination, auth, errors |
| `uc2-patch` | Add a partial-update endpoint | Required / omittable / nullable and PATCH semantics |
| `uc3-review` | Review a flawed contract without editing | Review-only behavior and finding quality |
| `uc4-breaking` | Breaking changes to a published contract | Applying explicit requests and flagging compatibility |
| `uc5-legacy` | Add an endpoint to TypeSpec that lives in `src/` | The `_contract/` rule for existing TypeSpec |

## Requirements

- bash with `find`, `sha256sum` and `cp` (Git Bash works on Windows)
- Node.js and npm. The first `setup.sh` run installs the TypeSpec packages pinned in `setup.sh` into the work directory so runs are comparable; this needs network access once.
- To test against your own toolchain instead, run with `SKIP_INSTALL=1` and make the compiler resolvable from the work directory (a `node_modules/` there, or a parent directory). Record the version you used in the results.

## Running

1. Prepare the runs in a work directory outside the repository:

   ```bash
   bash evals/scripts/setup.sh /tmp/skill-evals
   # optional: CASES="uc1-bookstore uc5-legacy" VARIANTS="skill" RUNS=2
   ```

2. For each file in `<work-dir>/prompts/`, start a fresh agent session and give it that prompt. Use one session per run and record the model.
3. Grade the machine checks:

   ```bash
   bash evals/scripts/grade.sh /tmp/skill-evals
   ```

4. Read each agent's final report, grade the report checks below, and record everything in `results/<date>.md`, including the model, the skill commit and the number of runs.

`grade.sh` checks seed integrity before anything else and compiles a copy in `<work-dir>/.grade/`, so grading never changes a run.

The `base` variant does not depend on the skill, so its earlier results can be reused. After changing the skill, rerun the `skill` variant.

## Rubric

| Case | Machine checks (`grade.sh`) | Report checks (manual) |
| --- | --- | --- |
| `uc1-bookstore` | TypeSpec only in `_contract/`; compiles; emits to `_contract/generated`; bearer security on every operation (top level or per operation); 404; page size max 100; 13-digit ISBN pattern; no binary float; currency property (the request names no single currency) | Assumptions are listed; each validation gate is PASS, FAIL or NOT RUN with a reason; failed compile attempts are counted |
| `uc2-patch` | Only `_contract/main.tsp` changed; compiles; PATCH operation; `name` has `minLength: 1`; `description` is nullable | Omitted and `null` semantics are stated; the read model's representation of a cleared `description` is addressed |
| `uc3-review` | Seed unchanged; no files created | Findings include the exposed `passwordHash`, missing authentication (401/403), client-settable `role`, unbounded pagination, and create returning 200 instead of 201 |
| `uc4-breaking` | Only `_contract/main.tsp` changed (published baseline untouched); compiles; `awaiting` emitted, `pending` removed; `legacyCode` removed; `region` required | Each change is flagged as breaking with who it affects and a compatible alternative; no silent substitution |
| `uc5-legacy` | Legacy files unchanged; change built in `_contract/`; compiles; history path emitted; `changedAt` is `date-time` | States which copy is authoritative; gives a migration plan (entrypoint, `tspconfig.yaml`, output directory) |

Every case also checks, in the report, that no roles, permissions or scopes were invented.

The `base` variant is expected to fail some checks, for example `uc5-legacy` editing `src/`.

## Limitations

- Runs are few, so results show tendencies rather than statistics.
- The rubric follows the skill's own rules; it measures conformance, not overall API quality.
- The prompt names the skill path, so automatic skill loading is not tested.
