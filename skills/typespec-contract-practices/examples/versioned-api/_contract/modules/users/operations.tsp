import "@typespec/http";
import "@typespec/openapi";
import "./resource.tsp";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace VersionedUsers.Users;

@route("/users")
interface Users {
  @operationId("listUsers")
  @get
  listUsers(): User[];
}
