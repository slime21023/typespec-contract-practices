import "@typespec/http";

using TypeSpec.Http;

namespace ProtectedUsers;

@error
model Unauthorized {
  @statusCode statusCode: 401;
}

@error
model Forbidden {
  @statusCode statusCode: 403;
}
