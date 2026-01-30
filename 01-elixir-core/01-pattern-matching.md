# Pattern Matching

**Usefulness: 10/10** - You'll use this in every single line of Elixir.

Pattern matching is not assignment. It's assertion + binding.

## The `=` Operator is Match, Not Assignment

```elixir
# This isn't "assign 1 to x"
# It's "match the right side and bind variables on the left"
x = 1

# This works
1 = x  # matches! x is 1

# This crashes
2 = x  # ** (MatchError) no match of right hand side value: 1
```

## Destructuring

Extract values from complex structures in one expression.

### Tuples

```elixir
{status, value} = {:ok, 42}
# status = :ok
# value = 42

# Partial match - only care about some values
{:ok, result} = {:ok, "success"}
# result = "success"

# This crashes if status isn't :ok
{:ok, result} = {:error, "failed"}  # MatchError!

# Nested destructuring
{:ok, {name, age}} = {:ok, {"Alice", 30}}
# name = "Alice"
# age = 30
```

### Lists

```elixir
[head | tail] = [1, 2, 3, 4]
# head = 1
# tail = [2, 3, 4]

[first, second | rest] = [1, 2, 3, 4]
# first = 1
# second = 2
# rest = [3, 4]

# Exact match
[a, b, c] = [1, 2, 3]
# Works

[a, b, c] = [1, 2]
# MatchError - different lengths
```

### Maps

```elixir
%{name: name, age: age} = %{name: "Bob", age: 25, city: "NYC"}
# name = "Bob"
# age = 25
# (city is ignored - maps match partially)

# Nested
%{user: %{name: name}} = %{user: %{name: "Alice", id: 1}}
# name = "Alice"
```

## The Pin Operator `^`

Use existing variable's value instead of rebinding.

```elixir
x = 1
{^x, y} = {1, 2}  # Works, x stays 1, y = 2
{^x, y} = {3, 2}  # MatchError! 3 doesn't match pinned x (1)
```

## Pattern Matching in Function Heads

This is where pattern matching shines. Multiple function clauses replace if/else chains.

```elixir
defmodule Greeting do
  def hello(:morning), do: "Good morning!"
  def hello(:afternoon), do: "Good afternoon!"
  def hello(:evening), do: "Good evening!"
  def hello(_), do: "Hello!"  # catch-all
end

Greeting.hello(:morning)  # "Good morning!"
Greeting.hello(:night)    # "Hello!"
```

### Processing Different Data Shapes

```elixir
defmodule Response do
  def handle({:ok, data}) do
    "Success: #{inspect(data)}"
  end

  def handle({:error, reason}) do
    "Failed: #{reason}"
  end

  def handle(:loading) do
    "Please wait..."
  end
end
```

### Recursive List Processing

```elixir
defmodule MyList do
  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)

  def map([], _func), do: []
  def map([head | tail], func), do: [func.(head) | map(tail, func)]
end

MyList.sum([1, 2, 3, 4])  # 10
MyList.map([1, 2, 3], fn x -> x * 2 end)  # [2, 4, 6]
```

## Guards

Add conditions to pattern matches.

```elixir
defmodule NumberCheck do
  def check(n) when n < 0, do: :negative
  def check(0), do: :zero
  def check(n) when n > 0, do: :positive
end

defmodule Auth do
  def access(user) when user.role == :admin, do: :full_access
  def access(user) when user.age >= 18, do: :standard_access
  def access(_user), do: :restricted
end
```

### Allowed in Guards

```elixir
# Comparison: ==, !=, <, >, <=, >=, ===, !==
# Boolean: and, or, not (NOT &&, ||, !)
# Arithmetic: +, -, *, /
# Type checks: is_atom/1, is_binary/1, is_boolean/1, is_float/1,
#              is_function/1, is_integer/1, is_list/1, is_map/1,
#              is_nil/1, is_number/1, is_pid/1, is_tuple/1
# Other: abs/1, elem/2, hd/1, tl/1, length/1, map_size/1,
#        tuple_size/1, in/2, byte_size/1, bit_size/1
```

## Case Expression

Pattern match against a value with multiple clauses.

```elixir
case File.read("config.json") do
  {:ok, content} ->
    Jason.decode!(content)

  {:error, :enoent} ->
    %{}  # File doesn't exist, use defaults

  {:error, reason} ->
    raise "Failed to read config: #{reason}"
end
```

With guards:

```elixir
case get_user(id) do
  %{role: :admin} = user ->
    admin_dashboard(user)

  %{age: age} = user when age >= 18 ->
    standard_dashboard(user)

  user ->
    restricted_dashboard(user)
end
```

## Common Patterns

### OK/Error Tuple Handling

```elixir
# The Elixir way - explicit handling
case fetch_data(url) do
  {:ok, data} -> process(data)
  {:error, reason} -> log_error(reason)
end

# With `with` for chaining (covered later)
with {:ok, response} <- fetch(url),
     {:ok, data} <- decode(response),
     {:ok, result} <- validate(data) do
  {:ok, result}
end
```

### Struct Matching

```elixir
defmodule User do
  defstruct [:name, :email, :role]
end

def greet(%User{name: name, role: :admin}) do
  "Welcome back, Admin #{name}!"
end

def greet(%User{name: name}) do
  "Hello, #{name}!"
end
```

### Binary Pattern Matching (Powerful!)

```elixir
# Parse a PNG file header
<<0x89, "PNG", 0x0D, 0x0A, 0x1A, 0x0A, rest::binary>> = png_data

# Parse network packets
<<version::4, header_length::4, rest::binary>> = ip_packet

# UTF-8 string extraction
<<first::utf8, rest::binary>> = "héllo"
# first = 104 (codepoint for 'h')
```

---

## Exercises

### Exercise 1: Basic Destructuring
```elixir
# Extract the coordinates from these tuples
point_2d = {3, 4}
point_3d = {1, 2, 3}
response = {:ok, %{x: 10, y: 20}}

# Your code here - bind x and y from each
```

### Exercise 2: List Patterns
```elixir
# Write a function that returns:
# - :empty for []
# - :single for [x]
# - :pair for [x, y]
# - :many for longer lists

defmodule ListSize do
  def classify(list) do
    # Your code here
  end
end
```

### Exercise 3: FizzBuzz with Pattern Matching
```elixir
# No if statements allowed!
# Use pattern matching on {rem(n, 3), rem(n, 5)}

defmodule FizzBuzz do
  def compute(n) do
    # Your code here
  end

  def run(max) do
    Enum.map(1..max, &compute/1)
  end
end
```

### Exercise 4: Recursive Sum
```elixir
# Implement sum/1 for nested lists
# sum([1, [2, 3], [[4]]]) should return 10

defmodule NestedSum do
  def sum(list) do
    # Your code here
    # Hint: match on is_list/1 in guards
  end
end
```

### Exercise 5: Parse Key-Value Strings
```elixir
# Parse "key=value" strings
# Return {:ok, {key, value}} or {:error, :invalid_format}
# Handle edge cases: empty string, no =, multiple =

defmodule KVParser do
  def parse(string) do
    # Your code here
    # Hint: String.split/2 with pattern matching
  end
end
```

### Exercise 6: Binary Parser
```elixir
# Parse a simple binary format:
# - First byte: message type (1 = text, 2 = binary)
# - Next 2 bytes: length (big endian)
# - Rest: payload

defmodule BinaryParser do
  def parse(<<type, length::16-big, payload::binary-size(length)>>) do
    # Your code here
  end
end
```

---

## Common Mistakes

### 1. Forgetting Maps Match Partially

```elixir
# This matches! Maps don't require all keys
%{a: 1} = %{a: 1, b: 2, c: 3}

# To require exact keys, use a guard or explicit check
```

### 2. Wrong Order of Function Clauses

```elixir
# BAD - catch-all first, other clauses never reached
def process(x), do: :default
def process(:special), do: :special  # Warning: never matches

# GOOD - specific first, catch-all last
def process(:special), do: :special
def process(x), do: :default
```

### 3. Matching in Wrong Context

```elixir
# Can't pattern match in the middle of expressions
# BAD
result = some_function() = expected_value

# GOOD
expected_value = some_function()
# or
case some_function() do
  ^expected_value -> :matched
  other -> {:different, other}
end
```

---

## Real-World Pattern

### API Response Handler

```elixir
defmodule ApiClient do
  def handle_response({:ok, %{status: 200, body: body}}) do
    {:ok, Jason.decode!(body)}
  end

  def handle_response({:ok, %{status: 201, body: body}}) do
    {:created, Jason.decode!(body)}
  end

  def handle_response({:ok, %{status: 204}}) do
    {:ok, nil}
  end

  def handle_response({:ok, %{status: status, body: body}})
      when status in 400..499 do
    {:client_error, status, body}
  end

  def handle_response({:ok, %{status: status}})
      when status in 500..599 do
    {:server_error, status}
  end

  def handle_response({:error, reason}) do
    {:connection_error, reason}
  end
end
```

No if statements. No case inside the function. Just pattern matching doing its job.
