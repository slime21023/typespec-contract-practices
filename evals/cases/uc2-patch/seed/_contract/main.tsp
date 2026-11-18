import "@typespec/http";
using TypeSpec.Http;

@service
namespace Catalog;

model Product {
  id: string;
  name: string;
  description?: string;
  priceMinor: int64;
  currency: string;
}

@route("/products")
interface Products {
  @get listProducts(): Product[];
  @get @route("/{productId}") getProduct(@path productId: string): Product;
  @post createProduct(@body input: Product): { @statusCode statusCode: 201; @body product: Product; };
}
