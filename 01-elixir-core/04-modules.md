# Modules

**Usefulness: 9/10** - All code lives in modules.

## Basic Module

```elixir
defmodule MyApp.User do
  @moduledoc """
  Handles user operations.
  """

  @doc """
  Creates a new user with the given name.
  """
  def new(name) do
    %{name: name, created_at: DateTime.utc_now()}
  end
end
```

## Module Attributes

Compile-time constants and metadata.

```elixir
defmodule Config do
  # Constants
  @timeout 5000
  @max_retries 3

  # Documentation
  @moduledoc "Configuration module"
  @doc "Returns the timeout value"

  # Typespec
  @spec get_timeout() :: integer()
  def get_timeout, do: @timeout

  # Accumulating attribute
  Module.register_attribute(__MODULE__, :endpoints, accumulate: true)
  @endpoints "/users"
  @endpoints "/posts"
  # @endpoints is now ["/posts", "/users"]
end
```

### Special Attributes

```elixir
@moduledoc   # Module documentation
@doc         # Function documentation
@spec        # Type specification
@behaviour   # Declare implemented behaviour
@impl        # Mark implementation of behaviour callback
@deprecated  # Mark as deprecated
@compile     # Compiler options
@before_compile  # Hook before compilation
@after_compile   # Hook after compilation
@on_definition   # Hook when function defined
```

---

## Import, Alias, Require, Use

### alias

Shortens module names.

```elixir
defmodule MyApp.Web.Controllers.UserController do
  alias MyApp.Accounts.User
  alias MyApp.Accounts.{User, Permission}  # Multiple

  # Now use User instead of MyApp.Accounts.User
  def show(id) do
    User.get(id)
  end
end

# Custom alias name
alias MyApp.Accounts.User, as: AccountUser
```

### import

Brings functions into current scope.

```elixir
defmodule Math do
  import Enum, only: [map: 2, filter: 2]
  import Enum, except: [map: 2]
  import Enum  # Import all (usually avoid)

  def double_evens(list) do
    list
    |> filter(&(rem(&1, 2) == 0))
    |> map(&(&1 * 2))
  end
end
```

### require

Needed for macros.

```elixir
require Logger

Logger.info("This works")

# Without require:
Logger.info("This fails")  # CompileError
```

### use

Injects code via `__using__` macro.

```elixir
defmodule MyApp.Web do
  defmacro __using__(_opts) do
    quote do
      import Plug.Conn
      import MyApp.Router.Helpers
      alias MyApp.Repo
    end
  end
end

defmodule MyApp.UserController do
  use MyApp.Web  # Injects imports and aliases
end
```

---

## Nested Modules

```elixir
defmodule Outer do
  defmodule Inner do
    def hello, do: "hello from inner"
  end

  def call_inner do
    Inner.hello()  # Can reference directly inside Outer
  end
end

Outer.Inner.hello()  # Full path from outside
```

**Note**: Nesting is just naming convention. `Outer.Inner` doesn't require `Outer` to exist.

```elixir
# These are independent modules
defmodule Foo.Bar.Baz do
end

# Foo and Foo.Bar don't need to exist
```

---

## Module Functions

```elixir
defmodule Example do
  # Check if module defines a function
  def has_hello? do
    function_exported?(__MODULE__, :hello, 0)
  end

  # Get module info
  def info do
    __MODULE__.__info__(:functions)
  end
end

# From outside
Code.ensure_loaded?(MyModule)
function_exported?(MyModule, :func, 2)
```

---

## Structs Revisited

Structs are defined inside modules and tied to them.

```elixir
defmodule User do
  defstruct [:name, :email]

  # Functions that operate on the struct
  def new(name, email) do
    %__MODULE__{name: name, email: email}
  end

  def formatted(%__MODULE__{name: name, email: email}) do
    "#{name} <#{email}>"
  end
end

User.new("Alice", "alice@example.com")
|> User.formatted()
```

---

## Module Compilation

```elixir
defmodule CompileExample do
  # Runs at compile time
  @files File.ls!("./lib")

  # Generated at compile time
  for file <- @files do
    def file_exists?(unquote(file)), do: true
  end
  def file_exists?(_), do: false
end
```

---

## Exercises

### Exercise 1: Module Organization
```elixir
# Organize these functions into appropriate modules:
# - create_user, update_user, delete_user
# - hash_password, verify_password
# - send_welcome_email, send_reset_email
# - log_event, get_events

# Create a module structure that makes sense
```

### Exercise 2: Use Macro
```elixir
# Create a module that when `use`d, automatically:
# - Imports Enum
# - Aliases the using module as `This`
# - Adds a `debug/1` function that prints with module name

defmodule Debuggable do
  defmacro __using__(_opts) do
    # Your code here
  end
end
```

### Exercise 3: Compile-Time Configuration
```elixir
# Create a module that reads config at compile time
# and generates functions based on it

# config.json: {"features": ["auth", "billing", "analytics"]}

defmodule Features do
  # Generate feature?(:auth), feature?(:billing), etc.
  # from config file at compile time
end
```

---

## Best Practices

### 1. One Module Per File

```
lib/
  my_app/
    accounts/
      user.ex       # MyApp.Accounts.User
      permission.ex # MyApp.Accounts.Permission
    accounts.ex     # MyApp.Accounts (context)
```

### 2. Context Modules

Group related functionality behind a facade.

```elixir
defmodule MyApp.Accounts do
  alias MyApp.Accounts.{User, Permission}

  def create_user(attrs), do: User.create(attrs)
  def get_user(id), do: User.get(id)
  def check_permission(user, perm), do: Permission.check(user, perm)
end
```

### 3. Avoid Deep Nesting

```elixir
# Avoid
MyApp.Web.Controllers.Api.V2.Users.AdminController

# Prefer
MyApp.Api.V2.UserAdminController
```
