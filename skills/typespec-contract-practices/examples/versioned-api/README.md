# versioned-api

Requires @typespec/versioning. Expected v1 omits displayName; v2 includes it as optional. Inspect actual emitted versions and paths.

Install mutually compatible versions of @typespec/compiler, @typespec/http, @typespec/openapi, @typespec/openapi3 (and @typespec/versioning when needed) using your project package manager. From _contract, run the installed compiler with `tsp compile .` after checking its CLI version. Inspect generated OpenAPI.

Validation: `tsp compile .` PASS with @typespec/compiler 1.18.0 (2026-11-18); lint and OpenAPI validation NOT RUN. These are illustrative fixtures, not production-ready contracts.
