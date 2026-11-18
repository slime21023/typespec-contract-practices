import "@typespec/http";
using TypeSpec.Http;

@service
namespace Shop;

enum OrderStatus { pending, shipped, delivered }

model Order {
  id: string;
  status: OrderStatus;
  total: int64;
  legacyCode?: string;
}

model CreateOrder {
  items: string[];
}

@route("/orders")
interface Orders {
  @get listOrders(): Order[];
  @get @route("/{orderId}") getOrder(@path orderId: string): Order;
  @post createOrder(@body input: CreateOrder): { @statusCode statusCode: 201; @body order: Order; };
}
