import "@typespec/versioning";

using TypeSpec.Versioning;

namespace VersionedUsers.Users;

model User {
  id: string;

  @added(Versions.v2)
  displayName?: string;
}
