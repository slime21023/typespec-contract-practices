import "@typespec/http";
import "@typespec/openapi";
import "./common/errors.tsp";
import "./modules/users";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

@service(#{ title: "Protected Users API" })
@useAuth(BearerAuth)
namespace ProtectedUsers;
