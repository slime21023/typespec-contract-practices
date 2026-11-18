# Authentication and authorization details

## Authentication

- Use supported `@typespec/http` auth types with `@useAuth`; identify public operations explicitly. Authentication is not authorization.
- `BearerAuth` describes bearer credentials, not JWT validation. OAuth scopes must come from the real registry.
- Verify emitted security at operation level, including overrides and public operations. Test missing and invalid credentials.

## Authorization

- Use authoritative identifiers; block affected edits if the registry or policy is missing.
- Prefer permission requirements over role enumeration unless a role restriction is part of the external contract.

## `x-authorization` extension

Extension keys start with `x-`; no authorization key is mandatory. Preserve an established project schema. For a new project, one operation-level extension may be adopted. It needs `@typespec/openapi` and existing identifiers.

```typespec
@extension("x-authorization", #{
  permissions: #{ allOf: #["users:read"] },
  resourcePolicy: "same-tenant"
})
```

Define explicitly: `roles.anyOf`, `roles.allOf`, `permissions.anyOf`, `permissions.allOf`, `resourcePolicy`.

- Every present `allOf` must match all members; every present `anyOf` must match at least one; groups combine with AND, e.g. (any role) AND (all permissions) AND resourcePolicy.
- Reject empty arrays and unknown IDs unless their semantics are defined.
- No implicit inheritance: each protected operation declares its policy, unless override rules are defined.
- Public operations cannot carry protected requirements.
- Missing, malformed or conflicting metadata denies access. Intentionally public operations are marked explicitly.
- The extension is metadata, not enforcement. Runtime must enforce tenant and ownership checks independently.
- Verify the emitted JSON/YAML structure. Test denied access: absent token, missing permission, cross-tenant request.
- Object values in TypeSpec use commas.
