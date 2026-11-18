import "@typespec/http";
import "@typespec/openapi";
import "./resource.tsp";
import "../../common/errors.tsp";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace ProtectedUsers.Users;

@route("/users")
interface Users {
  @operationId("getUser")
  @get
  @route("/{userId}")
  @extension(
    "x-authorization",
    #{ permissions: #{ allOf: #["users:read"] }, resourcePolicy: "same-tenant" }
  )
  getUser(@path userId: string): User | Unauthorized | Forbidden;
}
