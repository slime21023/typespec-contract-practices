import "@typespec/http";
import "@typespec/openapi";
import "./common/errors.tsp";
import "./modules/users";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

/** Public demo: no authentication. Production mutations need a security review. */
@service(#{ title: "Users API" })
namespace UsersApi;
