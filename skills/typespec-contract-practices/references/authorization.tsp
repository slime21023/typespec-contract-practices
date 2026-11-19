import "@typespec/http";
import "@typespec/openapi";

using Http;
using OpenAPI;

@service(#{ title: "Identity Service" })
@useAuth(BearerAuth)
namespace IdentityService;

alias PlatformOAuth<Scopes extends string[] = []> = OAuth2Auth<
  [
    {
      type: OAuth2FlowType.authorizationCode;
      authorizationUrl: "https://auth.example.com/oauth/authorize";
      tokenUrl: "https://auth.example.com/oauth/token";
      scopes: ["users:read", "users:write", "audit:export"];
    }
  ],
  Scopes
>;

@error
model ApiError {
  code: string;
  message: string;
}

model UnauthorizedError {
  @statusCode statusCode: 401;
  @body body: ApiError;
}

model ForbiddenError {
  @statusCode statusCode: 403;
  @body body: ApiError;
}

model NotFoundError {
  @statusCode statusCode: 404;
  @body body: ApiError;
}

model HealthStatus {
  status: "ok" | "degraded";
}

model User {
  id: string;
  tenantId: string;
  email: string;
}

model AuditExport {
  exportId: string;
  downloadUrl: url;
}

@route("/health")
@get
@useAuth(NoAuth)
op getHealth(): HealthStatus;

@route("/users/{userId}")
@get
@extension("x-authorization", #{
  permissions: #{ allOf: #["users:read"] },
  resourcePolicy: "same-tenant",
})
op getUser(@path userId: string): User | UnauthorizedError | ForbiddenError | NotFoundError;

@route("/users/{userId}")
@delete
@extension("x-authorization", #{
  permissions: #{
    allOf: #["users:delete"],
    anyOf: #["users:manage-members", "users:manage-admins"],
  },
  resourcePolicy: "same-tenant",
})
op deleteUser(@path userId: string): {
  @statusCode statusCode: 204;
} | UnauthorizedError | ForbiddenError | NotFoundError;

@route("/audit-exports")
@post
@useAuth(PlatformOAuth<["audit:export"]>)
@extension("x-authorization", #{
  roles: #{
    allOf: #["tenant-member"],
    anyOf: #["security-auditor", "compliance-officer"],
  },
  permissions: #{ allOf: #["audit:export"] },
  resourcePolicy: "same-tenant-verified-mfa",
})
op createAuditExport(): {
  @statusCode statusCode: 202;
  @body body: AuditExport;
} | UnauthorizedError | ForbiddenError;
