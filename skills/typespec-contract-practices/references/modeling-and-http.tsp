import "@typespec/http";
import "@typespec/openapi";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

@service(#{ title: "Store API" })
@info(#{ version: "1.0.0" })
namespace Store;

@format("uuid")
scalar OrderId extends string;

@pattern("^[0-9]+\\.[0-9]{2}$")
scalar DecimalAmount extends string;

@pattern("^[A-Z]{3}$")
scalar CurrencyCode extends string;

enum OrderStatus {
  draft,
  submitted,
  approved,
  cancelled,
}

model Money {
  amount: DecimalAmount;
  currency: CurrencyCode;
}

model ErrorBody {
  code: string;
  message: string;
  traceId?: string;
}

@error
model BadRequestError {
  @statusCode statusCode: 400;
  @body body: ErrorBody;
}

@error
model UnauthorizedError {
  @statusCode statusCode: 401;
  @body body: ErrorBody;
}

@error
model ForbiddenError {
  @statusCode statusCode: 403;
  @body body: ErrorBody;
}

@error
model NotFoundError {
  @statusCode statusCode: 404;
  @body body: ErrorBody;
}

@error
model ConflictError {
  @statusCode statusCode: 409;
  @body body: ErrorBody;
}

@error
model PreconditionFailedError {
  @statusCode statusCode: 412;
  @body body: ErrorBody;
}

@error
model RateLimitError {
  @statusCode statusCode: 429;
  @body body: ErrorBody;
}

model Page<Item> {
  items: Item[];
  nextCursor?: string | null;
}

model OrderItem {
  @minLength(1)
  sku: string;

  @minValue(1)
  quantity: int32;

  unitPrice: Money;
}

model Order {
  id: OrderId;
  status: OrderStatus;

  @minLength(1)
  @maxLength(120)
  customerName: string;

  @minItems(1)
  items: OrderItem[];

  total: Money;
  isGift: boolean;
  deliveryDate: plainDate;
  createdAt: utcDateTime;
  approvedAt: utcDateTime | null;
  note?: string | null;
  metadata?: Record<string>;
}

model CreateOrder {
  ...OmitProperties<Order, "id" | "status" | "total" | "createdAt" | "approvedAt">;
}

model UpdateOrder {
  deliveryDate?: plainDate;
  isGift?: boolean;
  note?: string | null;
}

model OrderCreated {
  @statusCode statusCode: 201;
  @body body: Order;
}

@route("/order-items")
interface OrderItems {
  @operationId("listOrders")
  @get
  listOrders(
    @query cursor?: string,
    @query @minValue(1) @maxValue(100) limit?: int32 = 20,
  ): Page<Order> | UnauthorizedError;

  @operationId("createOrder")
  @post
  createOrder(
    @header("Idempotency-Key") idempotencyKey: string,
    @body input: CreateOrder,
  ): OrderCreated | BadRequestError | UnauthorizedError | ConflictError | RateLimitError;

  @operationId("getOrder")
  @get
  @route("/{orderId}")
  getOrder(@path orderId: OrderId): Order | UnauthorizedError | NotFoundError;

  @operationId("updateOrder")
  @patch
  @route("/{orderId}")
  updateOrder(
    @path orderId: OrderId,
    @header("If-Match") ifMatch: string,
    @header contentType: "application/merge-patch+json",
    @body patch: UpdateOrder,
  ): Order | BadRequestError | UnauthorizedError | NotFoundError | PreconditionFailedError;

  @operationId("approveOrder")
  @post
  @route("/{orderId}/approve")
  approveOrder(
    @path orderId: OrderId,
    @header("Idempotency-Key") idempotencyKey: string,
  ): Order | UnauthorizedError | ForbiddenError | NotFoundError | ConflictError;

  @operationId("deleteOrder")
  @delete
  @route("/{orderId}")
  deleteOrder(
    @path orderId: OrderId,
  ): {
    @statusCode statusCode: 204;
  } | UnauthorizedError | NotFoundError;
}
