# basic-crud

Public demo only; production mutations require explicit security review. No pagination in this minimal example.

Layout: `main.tsp` declares the `UsersApi` service; `common/errors.tsp` holds the error body shared by all modules; `modules/users/` is split into `resource.tsp`, `requests.tsp`, `responses.tsp` and `operations.tsp` in the `UsersApi.Users` namespace, with explicit operation IDs.

Install mutually compatible versions of @typespec/compiler, @typespec/http, @typespec/openapi, @typespec/openapi3 (and @typespec/versioning when needed) using your project package manager. From _contract, run the installed compiler with `tsp compile .` after checking its CLI version. Inspect generated OpenAPI.

Validation: compiled successfully with `tsp compile .` when last checked; recompile with your installed compiler. Lint and OpenAPI validation NOT RUN. These are illustrative fixtures, not production-ready contracts.
