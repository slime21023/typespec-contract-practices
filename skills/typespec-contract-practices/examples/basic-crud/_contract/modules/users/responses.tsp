import "@typespec/http";
import "./resource.tsp";
import "../../common/errors.tsp";

using TypeSpec.Http;

namespace UsersApi.Users;

model UserCreated {
  @statusCode statusCode: 201;
  @body user: User;
}

model UserDeleted {
  @statusCode statusCode: 204;
}

@error
model UserNotFound {
  @statusCode statusCode: 404;
  @body body: ErrorBody;
}
