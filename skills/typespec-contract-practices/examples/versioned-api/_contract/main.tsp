import "@typespec/http";
import "@typespec/openapi";
import "@typespec/versioning";
import "./modules/users";

using TypeSpec.Http;
using TypeSpec.OpenAPI;
using TypeSpec.Versioning;

@service(#{ title: "Versioned Users API" })
@versioned(Versions)
namespace VersionedUsers;

enum Versions {
  v1: "v1",
  v2: "v2",
}
