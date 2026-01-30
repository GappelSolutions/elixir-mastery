# Protocols

**Usefulness: 8/10** - Polymorphism the Elixir way.

Protocols define a contract that different data types can implement. Like interfaces, but dispatched at runtime based on data type.

## Defining a Protocol

```elixir
defprotocol Size do
  @doc "Returns the size of the data structure"
  def size(data)
end
```

## Implementing for Types

```elixir
defimpl Size, for: BitString do
  def size(string), do: byte_size(string)
end

defimpl Size, for: Map do
  def size(map), do: map_size(map)
end

defimpl Size, for: Tuple do
  def size(tuple), do: tuple_size(tuple)
end

defimpl Size, for: List do
  def size(list), do: length(list)
end
```

## Using the Protocol

```elixir
Size.size("hello")      # 5
Size.size(%{a: 1, b: 2}) # 2
Size.size({1, 2, 3})    # 3
Size.size([1, 2, 3, 4]) # 4
```

## Implementing for Structs

```elixir
defmodule User do
  defstruct [:name, :email, :posts]
end

defimpl Size, for: User do
  def size(%User{posts: posts}) do
    length(posts)
  end
end

user = %User{name: "Alice", posts: [1, 2, 3]}
Size.size(user)  # 3
```

## Implementing Inside the Module

```elixir
defmodule User do
  defstruct [:name, :email]

  defimpl String.Chars do
    def to_string(%User{name: name, email: email}) do
      "#{name} <#{email}>"
    end
  end

  defimpl Inspect do
    def inspect(%User{name: name}, _opts) do
      "#User<#{name}>"
    end
  end
end

user = %User{name: "Alice", email: "a@b.com"}
to_string(user)  # "Alice <a@b.com>"
inspect(user)    # "#User<Alice>"
```

## Built-in Protocols

### Enumerable

Makes your type work with Enum functions.

```elixir
defmodule Countdown do
  defstruct [:from]

  defimpl Enumerable do
    def count(%Countdown{from: n}), do: {:ok, n + 1}

    def member?(%Countdown{from: n}, x) when x >= 0 and x <= n, do: {:ok, true}
    def member?(_, _), do: {:ok, false}

    def reduce(%Countdown{from: n}, acc, fun) do
      reduce_countdown(n, acc, fun)
    end

    defp reduce_countdown(_, {:halt, acc}, _fun), do: {:halted, acc}
    defp reduce_countdown(n, {:suspend, acc}, fun), do: {:suspended, acc, &reduce_countdown(n, &1, fun)}
    defp reduce_countdown(-1, {:cont, acc}, _fun), do: {:done, acc}
    defp reduce_countdown(n, {:cont, acc}, fun), do: reduce_countdown(n - 1, fun.(n, acc), fun)

    def slice(_), do: {:error, __MODULE__}
  end
end

Enum.to_list(%Countdown{from: 5})  # [5, 4, 3, 2, 1, 0]
Enum.map(%Countdown{from: 3}, &(&1 * 2))  # [6, 4, 2, 0]
```

### Collectable

Makes your type work with `Enum.into/2` and comprehensions.

```elixir
defimpl Collectable, for: MySet do
  def into(set) do
    collector_fun = fn
      set_acc, {:cont, elem} -> MySet.put(set_acc, elem)
      set_acc, :done -> set_acc
      _set_acc, :halt -> :ok
    end

    {set, collector_fun}
  end
end

# Now works with into:
Enum.into([1, 2, 3], %MySet{})
for x <- 1..10, into: %MySet{}, do: x
```

### String.Chars

Implements `to_string/1`.

```elixir
defimpl String.Chars, for: User do
  def to_string(%User{name: name}) do
    name
  end
end

"Hello, #{user}"  # Uses to_string
```

### Inspect

Controls `inspect/1` output.

```elixir
defimpl Inspect, for: User do
  import Inspect.Algebra

  def inspect(%User{name: name, email: email}, opts) do
    concat(["#User<", to_doc(name, opts), ", ", to_doc(email, opts), ">"])
  end
end
```

### Jason.Encoder

For JSON encoding (from Jason library).

```elixir
defimpl Jason.Encoder, for: User do
  def encode(%User{name: name, email: email}, opts) do
    Jason.Encode.map(%{name: name, email: email}, opts)
  end
end
```

## Fallback to Any

```elixir
defprotocol Size do
  @fallback_to_any true
  def size(data)
end

defimpl Size, for: Any do
  def size(_), do: 0
end

# Now any type without implementation returns 0
Size.size(:atom)  # 0
```

## Deriving

Automatically derive implementation using `Any`.

```elixir
defprotocol JSON do
  @fallback_to_any true
  def encode(data)
end

defimpl JSON, for: Any do
  def encode(%{__struct__: _} = struct) do
    struct
    |> Map.from_struct()
    |> JSON.encode()
  end

  def encode(data), do: inspect(data)
end

defmodule User do
  @derive [JSON]
  defstruct [:name, :email]
end

JSON.encode(%User{name: "Alice"})
```

## Protocol Consolidation

In production, protocols are consolidated for performance.

```elixir
# mix.exs
def project do
  [
    consolidate_protocols: Mix.env() != :test
  ]
end
```

---

## Exercises

### Exercise 1: Printable Protocol
```elixir
# Create a Printable protocol with pretty_print/1
# Implement for Map, List, and a custom struct

defprotocol Printable do
  def pretty_print(data)
end
```

### Exercise 2: Serializable
```elixir
# Create a Serializable protocol with:
# - serialize(data) -> binary
# - deserialize(binary, type) -> data
# Implement for common types
```

### Exercise 3: Custom Enumerable
```elixir
# Create a Range-like struct that:
# - Supports step
# - Implements Enumerable
# - Works with all Enum functions

defmodule StepRange do
  defstruct [:start, :stop, :step]
end
```

---

## Protocol vs Behaviour

| Protocol | Behaviour |
|----------|-----------|
| Dispatches on data type | Dispatches on module |
| Runtime polymorphism | Compile-time contracts |
| `defprotocol` + `defimpl` | `@callback` + `@impl` |
| For data transformation | For module contracts |
