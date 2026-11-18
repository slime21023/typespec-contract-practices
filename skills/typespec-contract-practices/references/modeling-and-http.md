# Modeling and HTTP details

## Naming

Defaults; preserve an established project convention.

| Element | Convention | Example |
| --- | --- | --- |
| Namespace, model, interface, enum, union, custom scalar | PascalCase | `User`, `UserStatus`, `UserId` |
| Property, parameter, operation, enum member, custom decorator | camelCase | `displayName`, `listUsers` |
| Built-in scalar | original name | `utcDateTime` |
| Source file | kebab-case | `user-operations.tsp` |
| Template parameter | descriptive PascalCase | `Item` |
| Route segment | lowercase kebab-case, plural collections | `/order-items/{itemId}` |
| Permission key (only if the project has none) | `<resource>:<action>` | `orders:approve` |

Prefer `listUsers`, `getUser`, `createUser` over `run`, `process`, `getAll`. Use public-contract vocabulary, not persistence or framework names (`UserEntityImpl`).

## Schema and models

- Optionality: `f: T` required; `f?: T` omittable; `f: T | null` required nullable; `f?: T | null` omittable nullable.
- Field-based PATCH: omitted means unchanged; `null` clears only if supported. JSON Patch and Merge Patch follow their own media types.
- Use separate writable and readable models when fields differ; never expose secrets, password hashes or internal administrative state.
- Use real wire types (`int32`, `int64`, `boolean`, `utcDateTime`, `plainDate`, typed arrays, records, enums), not `string` or `unknown` everywhere.
- Add constraints where meaningful: `@minLength`, `@maxLength`, `@minValue`, `@maxValue`, `@minItems`, `@format`.
- Money: minor units plus currency, or a defined decimal string; not binary floating point.
- Use templates only for genuine repetition; avoid deep inheritance and deeply nested anonymous schemas.
- Spread (`...M`), copy (`model A is B`) and `extends` can emit different schemas; check the emitted output instead of assuming equivalence.

```typespec
scalar UserId extends string;

model CreateUser {
  @minLength(1) displayName: string;
}
```

## HTTP

- Methods: `GET` read, `POST` create or command, `PUT` replace, `PATCH` partial update, `DELETE` delete. Commands need not be forced into CRUD.
- Use explicit decorators where ambiguous: `@route`, `@get`, `@post`, `@put`, `@patch`, `@delete`, `@path`, `@query`, `@header`, `@body`, `@statusCode`.
- Status codes: 200 retrieval, 201 creation, 204 no body, 400 malformed input, 401 unauthenticated, 403 forbidden, 404 missing, 409 conflict, 412 failed precondition, 429 rate limit. Standardize 422 if used.
- Errors: `@error` models with `@statusCode`; shared shape (`code`, safe `message`, optional `traceId`); no internal exceptions or sensitive existence details. Use 404 concealment only per established policy. Check actual response schemas and status codes.
- Pagination: one convention per API family (offset/limit or cursor) with explicit bounds, stable sorting and continuation semantics.
- Document retry/idempotency and concurrency preconditions for nontrivial mutations.
- Document operations as contracts, not implementation instructions.
