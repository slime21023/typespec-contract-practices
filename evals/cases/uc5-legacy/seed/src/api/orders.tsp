import "@typespec/http";
using TypeSpec.Http;

@service
namespace Orders;

model Order { id: string; status: string; }

@route("/orders")
interface Orders {
  @get listOrders(): Order[];
  @get @route("/{orderId}") getOrder(@path orderId: string): Order;
}
