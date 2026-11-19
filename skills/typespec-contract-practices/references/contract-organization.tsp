import "@typespec/http";
import "@typespec/openapi";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

@service(#{ title: "Bookstore" })
@info(#{ version: "1.0.0" })
@useAuth(BearerAuth)
namespace Bookstore;

model ErrorBody {
  code: string;
  message: string;
  traceId?: string;
}

@error
model NotFoundError {
  @statusCode statusCode: 404;
  @body body: ErrorBody;
}

model Author {
  id: string;
  name: string;
}

model CreateAuthor {
  ...OmitProperties<Author, "id">;
}

model AuthorPage {
  items: Author[];
}

model Book {
  isbn: string;
  title: string;
  authorId: string;
}

model CreateBook {
  ...OmitProperties<Book, "isbn">;
  isbn: string;
}

model UpdateBook {
  title?: string;
}

model BookCreated {
  @statusCode statusCode: 201;
  @body book: Book;
}

@route("/authors")
interface Authors {
  @operationId("listAuthors")
  @get
  listAuthors(): AuthorPage;

  @operationId("createAuthor")
  @post
  createAuthor(@body input: CreateAuthor): Author;

  @operationId("getAuthor")
  @get
  @route("/{id}")
  getAuthor(@path id: string): Author | NotFoundError;
}

@route("/books")
interface Books {
  @operationId("listBooks")
  @get
  listBooks(): Book[];

  @operationId("createBook")
  @post
  createBook(@body input: CreateBook): BookCreated;

  @operationId("getBook")
  @get
  @route("/{isbn}")
  getBook(@path isbn: string): Book | NotFoundError;

  @operationId("updateBook")
  @patch
  @route("/{isbn}")
  updateBook(@path isbn: string, @body input: UpdateBook): Book | NotFoundError;

  @operationId("getBookAuthor")
  @get
  @route("/{isbn}/author")
  getBookAuthor(@path isbn: string): Author | NotFoundError;
}
