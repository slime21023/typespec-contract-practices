# rbac-api

Sample registry: permission users:read, policy same-tenant. IAM role mapping is outside this contract. See authorization reference for sample semantics. Test absent token, missing permission and cross-tenant denial. No runtime implementation is supplied.

Install mutually compatible versions of @typespec/compiler, @typespec/http, @typespec/openapi, @typespec/openapi3 (and @typespec/versioning when needed) using your project package manager. From _contract, run the installed compiler with `tsp compile .` after checking its CLI version. Inspect generated OpenAPI.

Validation: compiled successfully with `tsp compile .` when last checked; recompile with your installed compiler. Lint and OpenAPI validation NOT RUN. Authorization and cross-tenant tests NOT RUN (no runtime). These are illustrative fixtures, not production-ready contracts.
