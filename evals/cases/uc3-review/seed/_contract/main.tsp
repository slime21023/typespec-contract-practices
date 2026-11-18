import "@typespec/http";
using TypeSpec.Http;

@service
namespace Accounts;

model User {
  id: string;
  email: string;
  passwordHash: string;
  role: string;
  createdAt: string;
}

model CreateUserRequest {
  email: string;
  password: string;
  role?: string;
}

@route("/users")
interface Users {
  @post createUser(@body input: CreateUserRequest): User;
  @get @route("/{userId}") getUser(@path userId: string): User;
  @delete @route("/{userId}") deleteUser(@path userId: string): { @statusCode statusCode: 200; @body body: { ok: boolean }; };
  @get listUsers(@query page?: int32, @query size?: int32): User[];
}
