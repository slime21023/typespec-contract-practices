import "./resource.tsp";

namespace UsersApi.Users;

model CreateUser {
  ...OmitProperties<User, "id">;
}
