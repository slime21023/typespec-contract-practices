import "@typespec/http";
import "@typespec/openapi";
import "@typespec/versioning";
using TypeSpec.Http;
using TypeSpec.OpenAPI;
using TypeSpec.Versioning;
@service
@versioned(Versions)
namespace VersionedUsers;
enum Versions { v1: "v1", v2: "v2" }
model User {
  id: string;
  @added(Versions.v2) displayName?: string;
}
@route("/users") @get op listUsers(): User[];
