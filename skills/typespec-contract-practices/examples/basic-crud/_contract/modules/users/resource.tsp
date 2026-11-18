namespace UsersApi.Users;

model User {
  id: string;

  @minLength(1)
  displayName: string;
}
