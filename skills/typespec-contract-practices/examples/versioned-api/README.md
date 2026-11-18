# versioned-api

Requires @typespec/versioning. Expected v1 omits displayName; v2 includes it as optional. Inspect actual emitted versions and paths.

Layout: `main.tsp` declares the service with `@versioned(Versions)` and the `Versions` enum; `modules/users/` uses `@added(Versions.v2)` from the parent namespace, in the `VersionedUsers.Users` namespace.

Install mutually compatible versions of @typespec/compiler, @typespec/http, @typespec/openapi, @typespec/openapi3 (and @typespec/versioning when needed) using your project package manager. From _contract, run the installed compiler with `tsp compile .` after checking its CLI version. Inspect generated OpenAPI.

Validation: compiled successfully with `tsp compile .` when last checked; recompile with your installed compiler. Lint and OpenAPI validation NOT RUN. These are illustrative fixtures, not production-ready contracts.
