import "@typespec/http";
import "@typespec/openapi";
using TypeSpec.Http;
using TypeSpec.OpenAPI;
@service
namespace UsersApi;

model User {
  id: string;
  displayName: string;
}
model CreateUser {
  @minLength(1) displayName: string;
}
@error model NotFound {
  @statusCode statusCode: 404;
  @body body: { code: string; message: string; };
}
@route("/users")
interface Users {
  @get listUsers(): User[];
  @get @route("/{userId}") getUser(@path userId: string): User | NotFound;
  @post createUser(@body input: CreateUser): { @statusCode statusCode: 201; @body user: User; };
  @delete @route("/{userId}") deleteUser(@path userId: string): { @statusCode statusCode: 204; } | NotFound;
}
