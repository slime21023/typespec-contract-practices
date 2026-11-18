# Contract organization

Why the organization rules in SKILL.md §2 exist, what they rest on, and a complete example. Items marked "compiled" were checked against both an older and a current compiler release. Recheck anything version-sensitive with the installed compiler.

## Basis

| Practice | Basis |
| --- | --- |
| kebab-case files; PascalCase namespaces and interfaces (no `I` prefix); camelCase operations and properties | TypeSpec style guide |
| One blockless `namespace X;` per file, after the imports; namespaces merge across files | TypeSpec namespaces documentation |
| `import "./modules/books";` loads `modules/books/main.tsp` | TypeSpec imports documentation |
| Models in `Bookstore.Books` emit as `Books.Book`; models in the service namespace emit unprefixed | compiled |
| Module code resolves parent-namespace names (`ErrorBody`) without `using`; another module's names (`Author`) fail with `invalid-ref` unless fully qualified | compiled |
| `@useAuth` on the service namespace emits top-level security that covers every module | compiled |
| `@operationId("listBooks")` emits exactly `listBooks`; without it the ID is `<Interface>_<operation>`, e.g. `Books_getBook` | compiled |
| `@versioned` on the service namespace with `@added` inside a module emits one file per version | compiled |
| Splitting or merging files without changing namespaces leaves the emitted OpenAPI identical | compiled |
| Missing imports between project files and import cycles still compile | compiled; the dependency rules are conventions to review |

## Why each practice

- **One entrypoint, directory imports.** The compiler starts at `_contract/main.tsp` and loads only what it imports. Importing module directories keeps the entrypoint a short table of contents; adding a module adds one line.
- **Always split by responsibility.** Every definition has one obvious place, reviews show which responsibility changed, and adding a resource never forces a reorganization. File layout does not change the emitted contract.
- **A namespace per module.** Modules can reuse short names (`NotFound`, `Page`) without colliding, and emitted schema names show their owner. The cost is a module prefix in schema names, which SDK generators turn into type names. Choose before publishing, because moving a published model later renames its schema.
- **Fully qualified names across modules.** The dependency is visible where it is used. A sibling `using` also compiles, but resolves relative to the file namespace and hides where a name comes from.
- **Explicit operation IDs.** Operation IDs become SDK method names. Explicit IDs keep them short and independent of interface names, namespaces and file layout.
- **One-way dependencies.** Requests and responses both describe the resource and do not need each other. The compiler does not enforce this, so import cycles go unnoticed unless the rule is followed.

## Example

A bookstore with two modules. The Books module refers to an author with a fully qualified name. Each file below is shown in full and compiles as written.

```text
_contract/
  main.tsp
  tspconfig.yaml
  common/errors.tsp
  modules/
    books/    main.tsp  resource.tsp  requests.tsp  responses.tsp  operations.tsp
    authors/  main.tsp  resource.tsp  requests.tsp  responses.tsp  operations.tsp
```

**`_contract/tspconfig.yaml`**

```yaml
emit:
  - "@typespec/openapi3"
options:
  "@typespec/openapi3":
    emitter-output-dir: "{project-root}/generated"
```

**`_contract/main.tsp`**

```typespec
import "@typespec/http";
import "@typespec/openapi";
import "./common/errors.tsp";
import "./modules/books";
import "./modules/authors";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

@service(#{ title: "Bookstore" })
@info(#{ version: "1.0.0" })
@useAuth(BearerAuth)
namespace Bookstore;
```

**`_contract/common/errors.tsp`**

```typespec
namespace Bookstore;

model ErrorBody {
  code: string;
  message: string;
  traceId?: string;
}
```

**`_contract/modules/books/main.tsp`**

```typespec
import "./resource.tsp";
import "./requests.tsp";
import "./responses.tsp";
import "./operations.tsp";
```

**`_contract/modules/books/resource.tsp`**

```typespec
namespace Bookstore.Books;

model Book {
  isbn: string;
  title: string;
  authorId: string;
}
```

**`_contract/modules/books/requests.tsp`**

```typespec
import "./resource.tsp";

namespace Bookstore.Books;

model CreateBook {
  ...OmitProperties<Book, "isbn">;
  isbn: string;
}

model UpdateBook {
  title?: string;
}
```

**`_contract/modules/books/responses.tsp`**

```typespec
import "@typespec/http";
import "./resource.tsp";
import "../../common/errors.tsp";

using TypeSpec.Http;

namespace Bookstore.Books;

model BookCreated {
  @statusCode statusCode: 201;
  @body book: Book;
}

@error
model BookNotFound {
  @statusCode statusCode: 404;
  @body body: ErrorBody;
}
```

**`_contract/modules/books/operations.tsp`**

```typespec
import "@typespec/http";
import "@typespec/openapi";
import "./resource.tsp";
import "./requests.tsp";
import "./responses.tsp";
import "../authors/resource.tsp";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Bookstore.Books;

@route("/books")
interface Books {
  @operationId("listBooks") @get listBooks(): Book[];
  @operationId("createBook") @post createBook(
    @body input: CreateBook,
  ): BookCreated;
  @operationId("getBookAuthor")
  @get
  @route("/{isbn}/author")
  getBookAuthor(@path isbn: string): Bookstore.Authors.Author | BookNotFound;
  @operationId("getBook")
  @get
  @route("/{isbn}")
  getBook(@path isbn: string): Book | BookNotFound;
}
```

**`_contract/modules/authors/main.tsp`**

```typespec
import "./resource.tsp";
import "./requests.tsp";
import "./responses.tsp";
import "./operations.tsp";
```

**`_contract/modules/authors/resource.tsp`**

```typespec
namespace Bookstore.Authors;

model Author {
  id: string;
  name: string;
}
```

**`_contract/modules/authors/requests.tsp`**

```typespec
import "./resource.tsp";

namespace Bookstore.Authors;

model CreateAuthor {
  ...OmitProperties<Author, "id">;
}
```

**`_contract/modules/authors/responses.tsp`**

```typespec
import "./resource.tsp";

namespace Bookstore.Authors;

model AuthorPage {
  items: Author[];
}
```

**`_contract/modules/authors/operations.tsp`**

```typespec
import "@typespec/http";
import "@typespec/openapi";
import "./resource.tsp";
import "./requests.tsp";
import "./responses.tsp";

using TypeSpec.Http;
using TypeSpec.OpenAPI;

namespace Bookstore.Authors;

@route("/authors")
interface Authors {
  @operationId("listAuthors") @get listAuthors(): AuthorPage;
  @operationId("createAuthor") @post createAuthor(
    @body input: CreateAuthor,
  ): Author;
}
```

## Common mistakes

| Avoid | Do instead |
| --- | --- |
| Models or operations in `_contract/main.tsp` | Put them in a module |
| `namespace Bookstore.Books { ... }` | `namespace Bookstore.Books;` after the imports |
| `Author` referenced from the Books module | `Bookstore.Authors.Author` |
| `@statusCode` or `@error` in `requests.tsp` | `responses.tsp`, or `common/errors.tsp` when shared |
| `requests.tsp` importing `responses.tsp` | Both import `resource.tsp` |
| A file relying on another file's imports | Import every library and file the file uses |
| `CreateBook` repeating `Book`'s fields | `...OmitProperties<Book, "isbn">` |
| A new operation without `@operationId` | `@operationId("listBooks")` |
| `security/auth.tsp` holding one alias | `@useAuth` in `main.tsp` |
| A `common/` definition that fewer than two modules use | Keep it in the module that uses it, or remove it |
| `@operationId("getOrderHistory")` added next to existing `Orders_getOrder`-style IDs | Follow the existing style: omit `@operationId`, emitting `Orders_getOrderHistory` |
| Moving a published model into a module namespace | Keep its namespace; the schema name would change |

## Existing projects and copies

- Keep an existing project's layout, namespaces and operation IDs, and put new work where its structure puts it. New operations follow the contract's existing operation ID style, so one interface never mixes explicit IDs with `<Interface>_<operation>` defaults.
- When TypeSpec outside `_contract/` is copied in, split the copy by responsibility but keep its original namespaces and operation IDs. Its emitted names and SDK methods then stay the same. State which copy is authoritative until the migration is done.
