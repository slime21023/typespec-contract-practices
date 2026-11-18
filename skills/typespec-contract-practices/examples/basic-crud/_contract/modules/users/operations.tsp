import "@typespec/http";
import "@typespec/openapi";
import "./resource.tsp";
import "./requests.tsp";
import "./responses.tsp";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace UsersApi.Users;

@route("/users")
interface Users {
  @operationId("listUsers")
  @get
  listUsers(): User[];

  @operationId("getUser")
  @get
  @route("/{userId}")
  getUser(@path userId: string): User | UserNotFound;

  @operationId("createUser")
  @post
  createUser(@body input: CreateUser): UserCreated;

  @operationId("deleteUser")
  @delete
  @route("/{userId}")
  deleteUser(@path userId: string): UserDeleted | UserNotFound;
}
