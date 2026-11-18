import "@typespec/http";
import "@typespec/openapi";
using TypeSpec.Http;
using TypeSpec.OpenAPI;
@service
@useAuth(BearerAuth)
namespace ProtectedUsers;

model User { id: string; displayName: string; }
@error model Unauthorized { @statusCode statusCode: 401; }
@error model Forbidden { @statusCode statusCode: 403; }
@route("/users/{userId}")
@get
@extension("x-authorization", #{ permissions: #{ allOf: #["users:read"] }, resourcePolicy: "same-tenant" })
op getUser(@path userId: string): User | Unauthorized | Forbidden;
