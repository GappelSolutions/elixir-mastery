# Metaprogramming

Write code that writes code. Elixir's secret weapon for DSLs.

## Learning Order

1. [Quote & Unquote](01-quote-unquote.md)
2. [Macros](02-macros.md)
3. [AST Manipulation](03-ast.md)
4. [Using use](04-using-use.md)
5. [Compile Hooks](05-compile-hooks.md)

## Quote

Convert code to its AST (Abstract Syntax Tree).

```elixir
quote do
  1 + 2
end
# {:+, [context: Elixir, imports: [{1, Kernel}, {2, Kernel}]], [1, 2]}

quote do
  User.get(id)
end
# {{:., [], [{:__aliases__, [], [:User]}, :get]}, [], [{:id, [], Elixir}]}
```

## Unquote

Inject values into quoted code.

```elixir
name = :alice
quote do
  hello(unquote(name))
end
# {:hello, [], [:alice]}

# Without unquote, name is just an AST node
quote do
  hello(name)
end
# {:hello, [], [{:name, [], Elixir}]}
```

## Macros

Functions that run at compile time, receiving and returning AST.

```elixir
defmodule MyMacros do
  defmacro unless(condition, do: block) do
    quote do
      if !unquote(condition) do
        unquote(block)
      end
    end
  end
end

# Usage
require MyMacros
MyMacros.unless false do
  IO.puts("This runs!")
end
```

### Macro Hygiene

Variables in macros don't leak.

```elixir
defmacro hygienic do
  quote do
    x = 1  # This x is isolated
    x
  end
end

x = 10
hygienic()  # Returns 1
x           # Still 10

# Escape hygiene with var!
defmacro unhygienic do
  quote do
    var!(x) = 1  # Modifies caller's x
  end
end
```

## Common Patterns

### Compile-Time Code Generation

```elixir
defmodule Routes do
  @routes [
    {:get, "/users", :list_users},
    {:get, "/users/:id", :get_user},
    {:post, "/users", :create_user}
  ]

  for {method, path, handler} <- @routes do
    def route(unquote(method), unquote(path)) do
      unquote(handler)
    end
  end
end
```

### DSL Creation

```elixir
defmodule Schema do
  defmacro field(name, type) do
    quote do
      @fields {unquote(name), unquote(type)}
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def __fields__, do: @fields
    end
  end
end

defmodule User do
  @before_compile Schema
  Module.register_attribute(__MODULE__, :fields, accumulate: true)

  import Schema
  field :name, :string
  field :age, :integer
end

User.__fields__()  # [{:age, :integer}, {:name, :string}]
```

### Using `use`

```elixir
defmodule Loggable do
  defmacro __using__(opts) do
    level = Keyword.get(opts, :level, :info)
    quote do
      require Logger

      def log(message) do
        Logger.unquote(level)(message)
      end
    end
  end
end

defmodule MyModule do
  use Loggable, level: :debug

  def do_work do
    log("Starting work")  # Uses Logger.debug
  end
end
```

## AST Structure

```elixir
# Literals
quote do: 42          # 42
quote do: "hello"     # "hello"
quote do: :atom       # :atom
quote do: [1, 2, 3]   # [1, 2, 3]

# Calls
quote do: foo(1, 2)   # {:foo, [], [1, 2]}

# Operators
quote do: 1 + 2       # {:+, [...], [1, 2]}

# Blocks
quote do
  x = 1
  x + 1
end
# {:__block__, [], [{:=, [], [{:x, [], Elixir}, 1]}, {:+, [...], [{:x, [], Elixir}, 1]}]}
```

## Macro Debugging

```elixir
# See expanded code
require MyMacros
Macro.expand(quote(do: MyMacros.my_macro()), __ENV__)

# Pretty print AST
quote do: 1 + 2 |> Macro.to_string()  # "1 + 2"
```

---

## Exercises

### Exercise 1: assert Macro
```elixir
# Implement assert that shows:
# - Expression that failed
# - Left and right values

assert 1 + 1 == 3
# ** (AssertionError)
#    Expression: 1 + 1 == 3
#    Left:  2
#    Right: 3
```

### Exercise 2: defrecord Macro
```elixir
# Create a macro that generates:
# - Struct
# - Constructor
# - Getter functions

defrecord User, name: "", age: 0
# Generates: %User{}, User.new(), User.name(user), User.age(user)
```

### Exercise 3: Router DSL
```elixir
# Build a simple router DSL

defmodule MyRouter do
  use Router

  get "/", HomeController, :index
  get "/users/:id", UserController, :show
  post "/users", UserController, :create
end
```

### Exercise 4: Test DSL
```elixir
# Build a test framework like ExUnit

defmodule MyTest do
  use TestFramework

  test "addition works" do
    assert 1 + 1 == 2
  end

  test "subtraction works" do
    assert 5 - 3 == 2
  end
end
```

---

## Warnings

1. **Don't overuse macros** - Prefer functions when possible
2. **Macros are harder to debug** - Stack traces show expanded code
3. **Compile-time vs runtime** - Macro args are AST, not values
4. **Hygiene matters** - Use `var!` sparingly
5. **Test the expansion** - Not just the final behavior

## When to Use Macros

- DSLs (domain-specific languages)
- Compile-time code generation
- Wrapping/decorating functions
- Removing boilerplate
- Performance (inline code)

## When NOT to Use Macros

- Simple data transformation (use functions)
- Runtime logic (macros run at compile time)
- When a function would suffice
- If it makes code harder to understand
