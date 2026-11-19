import "@typespec/http";
import "@typespec/openapi";
import "@typespec/versioning";

using TypeSpec.Http;
using TypeSpec.OpenAPI;
using TypeSpec.Versioning;

@service(#{ title: "Bookstore" })
@useAuth(BearerAuth)
@versioned(Versions)
namespace Bookstore;

enum Versions {
  v1,
  v2,
}

enum OrderStatus {
  awaiting: "pending",
  confirmed: "confirmed",

  @added(Versions.v2)
  shipped: "shipped",
}

model ErrorBody {
  code: string;
  message: string;
}

@error
model UnauthorizedError {
  @statusCode statusCode: 401;
  @body body: ErrorBody;
}

@error
model NotFoundError {
  @statusCode statusCode: 404;
  @body body: ErrorBody;
}

model Order {
  id: string;
  status: OrderStatus;

  #deprecated "Use trackingCode instead."
  legacyCode?: string;

  @added(Versions.v2)
  trackingCode?: string;
}

@route("/orders")
interface Orders {
  @operationId("listOrders")
  @get
  @extension("x-authorization", #{
    permissions: #{ allOf: #["orders:read"] },
    resourcePolicy: "same-tenant",
  })
  listOrders(): Order[] | UnauthorizedError;

  @operationId("getOrder")
  @get
  @route("/{orderId}")
  @extension("x-authorization", #{
    permissions: #{ allOf: #["orders:read"] },
    resourcePolicy: "same-tenant",
  })
  getOrder(@path orderId: string): Order | UnauthorizedError | NotFoundError;

  @added(Versions.v2)
  @operationId("cancelOrder")
  @post
  @route("/{orderId}/cancel")
  @extension("x-authorization", #{
    permissions: #{ allOf: #["orders:cancel"] },
    resourcePolicy: "same-tenant",
  })
  cancelOrder(@path orderId: string): Order | UnauthorizedError | NotFoundError;
}
