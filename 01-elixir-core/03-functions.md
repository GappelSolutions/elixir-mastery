# Functions

**Usefulness: 10/10** - Functions are first-class citizens.

## Anonymous Functions

Functions without names. Created with `fn`.

```elixir
add = fn a, b -> a + b end
add.(1, 2)  # 3  (note the dot!)

# Shorthand with capture operator
add = &(&1 + &2)
add.(1, 2)  # 3

# Multi-clause anonymous functions
handle = fn
  {:ok, value} -> "Success: #{value}"
  {:error, reason} -> "Error: #{reason}"
end

handle.({:ok, 42})      # "Success: 42"
handle.({:error, "no"}) # "Error: no"
```

### Capture Operator `&`

Capture existing functions or create shorthand lambdas.

```elixir
# Capture named function
upcase = &String.upcase/1
upcase.("hello")  # "HELLO"

# Capture with arity
Enum.map([1, 2, 3], &Integer.to_string/1)  # ["1", "2", "3"]

# Shorthand lambda
Enum.map([1, 2, 3], &(&1 * 2))  # [2, 4, 6]

# Multiple arguments
Enum.reduce([1, 2, 3], 0, &(&1 + &2))  # 6
# Same as: fn x, acc -> x + acc end

# Capture Kernel functions
Enum.map([1, 2, 3], &to_string/1)  # ["1", "2", "3"]
```

### Closures

Functions capture their environment.

```elixir
multiplier = fn factor ->
  fn x -> x * factor end
end

double = multiplier.(2)
triple = multiplier.(3)

double.(5)  # 10
triple.(5)  # 15
```

---

## Named Functions

Defined with `def` inside modules.

```elixir
defmodule Math do
  def add(a, b) do
    a + b
  end

  # One-liner syntax
  def subtract(a, b), do: a - b
end

Math.add(1, 2)  # 3
Math.subtract(5, 3)  # 2
```

### Private Functions

Only callable within the module.

```elixir
defmodule Auth do
  def authenticate(username, password) do
    user = find_user(username)
    check_password(user, password)
  end

  defp find_user(username) do
    # Private - can't call Auth.find_user/1 from outside
    %{username: username}
  end

  defp check_password(user, password) do
    # Also private
    true
  end
end
```

### Default Arguments

```elixir
defmodule Greeter do
  def hello(name, greeting \\ "Hello") do
    "#{greeting}, #{name}!"
  end
end

Greeter.hello("Alice")            # "Hello, Alice!"
Greeter.hello("Alice", "Welcome") # "Welcome, Alice!"
```

**Warning**: Default arguments create multiple function clauses.

```elixir
defmodule Example do
  # This creates greet/1 and greet/2
  def greet(name, opts \\ [])

  def greet(name, opts) when is_list(opts) do
    # Implementation
  end
end
```

### Multiple Clauses with Defaults

```elixir
# Must define defaults in a header clause
defmodule Parser do
  def parse(input, opts \\ [])

  def parse(input, opts) when is_binary(input) do
    # Handle string
  end

  def parse(input, opts) when is_list(input) do
    # Handle charlist
  end
end
```

---

## Function Arity

Functions are identified by name AND arity (argument count).

```elixir
defmodule Example do
  def greet, do: "Hello!"
  def greet(name), do: "Hello, #{name}!"
  def greet(first, last), do: "Hello, #{first} #{last}!"
end

# These are THREE different functions:
# Example.greet/0
# Example.greet/1
# Example.greet/2
```

### Referencing Functions

```elixir
&Example.greet/0  # Captures greet/0
&Example.greet/1  # Captures greet/1
&Example.greet/2  # Captures greet/2

# Using in higher-order functions
Enum.map(["Alice", "Bob"], &Example.greet/1)
```

---

## Guard Clauses

Add conditions to function heads.

```elixir
defmodule Guard do
  def check(x) when is_integer(x) and x > 0 do
    :positive_integer
  end

  def check(x) when is_integer(x) and x < 0 do
    :negative_integer
  end

  def check(0), do: :zero

  def check(x) when is_float(x) do
    :float
  end

  def check(_), do: :other
end
```

### Custom Guards

```elixir
defmodule MyGuards do
  defguard is_adult(age) when is_integer(age) and age >= 18
  defguard is_even(n) when is_integer(n) and rem(n, 2) == 0
end

defmodule User do
  import MyGuards

  def can_vote?(age) when is_adult(age), do: true
  def can_vote?(_), do: false
end
```

---

## Pipe Operator `|>`

Chains function calls. Previous result becomes first argument.

```elixir
# Without pipe
String.trim(String.downcase(String.replace("  HELLO WORLD  ", " ", "-")))

# With pipe
"  HELLO WORLD  "
|> String.replace(" ", "-")
|> String.downcase()
|> String.trim()
# "--hello-world--"

# Complex transformation
users
|> Enum.filter(&(&1.active))
|> Enum.map(&(&1.email))
|> Enum.sort()
|> Enum.take(10)
```

### Pipe-Friendly Function Design

```elixir
# GOOD - data as first argument
defmodule User do
  def set_name(user, name), do: %{user | name: name}
  def set_age(user, age), do: %{user | age: age}
end

%User{}
|> User.set_name("Alice")
|> User.set_age(30)

# BAD - data not first
defmodule BadUser do
  def set_name(name, user), do: %{user | name: name}
end
# Can't pipe nicely
```

### When Not to Pipe

```elixir
# Awkward - conditional logic
user
|> validate()
|> (fn result ->
      case result do
        {:ok, user} -> save(user)
        {:error, _} = error -> error
      end
    end).()

# Better - use `with` or explicit variables
with {:ok, user} <- validate(user) do
  save(user)
end
```

---

## Higher-Order Functions

Functions that take or return functions.

```elixir
defmodule HOF do
  # Takes a function
  def apply_twice(func, value) do
    func.(func.(value))
  end

  # Returns a function
  def make_adder(n) do
    fn x -> x + n end
  end

  # Both
  def compose(f, g) do
    fn x -> f.(g.(x)) end
  end
end

double = fn x -> x * 2 end
HOF.apply_twice(double, 5)  # 20

add5 = HOF.make_adder(5)
add5.(10)  # 15

upcase_trim = HOF.compose(&String.upcase/1, &String.trim/1)
upcase_trim.("  hello  ")  # "HELLO"
```

---

## Recursion

No loops. Recursion is the way.

### Basic Recursion

```elixir
defmodule Recursive do
  def factorial(0), do: 1
  def factorial(n) when n > 0 do
    n * factorial(n - 1)
  end
end

Recursive.factorial(5)  # 120
```

### Tail Recursion

Last operation is the recursive call. Optimized by BEAM.

```elixir
defmodule TailRecursive do
  def factorial(n), do: factorial(n, 1)

  defp factorial(0, acc), do: acc
  defp factorial(n, acc) when n > 0 do
    factorial(n - 1, n * acc)  # Tail position!
  end
end
```

### List Processing

```elixir
defmodule MyEnum do
  def map([], _func), do: []
  def map([head | tail], func) do
    [func.(head) | map(tail, func)]
  end

  # Tail-recursive version
  def map_tail(list, func), do: do_map(list, func, [])

  defp do_map([], _func, acc), do: Enum.reverse(acc)
  defp do_map([head | tail], func, acc) do
    do_map(tail, func, [func.(head) | acc])
  end
end
```

---

## Exercises

### Exercise 1: Function Composition
```elixir
# Implement pipe/2 that takes a value and list of functions
# pipe(5, [&(&1 + 1), &(&1 * 2), &Integer.to_string/1])
# => "12"

defmodule Pipe do
  def pipe(value, functions) do
    # Your code here
  end
end
```

### Exercise 2: Currying
```elixir
# Implement curry/1 that converts a 2-arg function to curried form
# add = fn a, b -> a + b end
# curried = curry(add)
# curried.(1).(2) => 3

defmodule Curry do
  def curry(func) do
    # Your code here
  end
end
```

### Exercise 3: Memoization
```elixir
# Implement a memoized fibonacci using an Agent for cache
# fib(40) should be fast on repeated calls

defmodule Fib do
  def start_cache do
    Agent.start_link(fn -> %{} end, name: :fib_cache)
  end

  def fib(n) do
    # Your code here
    # Check cache, compute if missing, store result
  end
end
```

### Exercise 4: Retry Logic
```elixir
# Implement retry/3 that retries a function n times on failure
# retry(fn -> might_fail() end, 3, 100)
# Tries up to 3 times, waiting 100ms between attempts

defmodule Retry do
  def retry(func, attempts, delay_ms) do
    # Return {:ok, result} or {:error, last_error}
  end
end
```

### Exercise 5: Function Pipeline Builder
```elixir
# Build a composable pipeline that can be executed later
# pipeline = Pipeline.new()
#   |> Pipeline.add(&String.trim/1)
#   |> Pipeline.add(&String.upcase/1)
# Pipeline.run(pipeline, "  hello  ") => "HELLO"

defmodule Pipeline do
  defstruct functions: []

  def new, do: %Pipeline{}

  def add(pipeline, func) do
    # Your code here
  end

  def run(pipeline, value) do
    # Your code here
  end
end
```

---

## Common Patterns

### The `with` Pattern

Chain operations that might fail.

```elixir
def process_user(params) do
  with {:ok, user} <- create_user(params),
       {:ok, user} <- validate_email(user),
       {:ok, user} <- save_user(user) do
    {:ok, user}
  else
    {:error, :invalid_email} -> {:error, "Email is invalid"}
    {:error, :save_failed} -> {:error, "Could not save user"}
    error -> error
  end
end
```

### Options Pattern

```elixir
defmodule Http do
  @defaults [timeout: 5000, retries: 3]

  def get(url, opts \\ []) do
    opts = Keyword.merge(@defaults, opts)
    timeout = Keyword.fetch!(opts, :timeout)
    retries = Keyword.fetch!(opts, :retries)
    # ...
  end
end

Http.get("http://example.com", timeout: 10_000)
```

### Builder Pattern

```elixir
defmodule Query do
  defstruct table: nil, select: "*", where: [], limit: nil

  def from(table), do: %Query{table: table}

  def select(query, fields), do: %{query | select: fields}

  def where(query, condition) do
    %{query | where: [condition | query.where]}
  end

  def limit(query, n), do: %{query | limit: n}

  def to_sql(%Query{} = q) do
    "SELECT #{q.select} FROM #{q.table}" <>
    build_where(q.where) <>
    build_limit(q.limit)
  end
end

Query.from("users")
|> Query.select("name, email")
|> Query.where("active = true")
|> Query.limit(10)
|> Query.to_sql()
```

---

## Gotchas

### Dot Notation for Anonymous Functions

```elixir
named = fn x -> x end
named.(1)  # Need the dot!

# But not for named functions
String.upcase("hello")  # No dot
```

### Default Arguments and Pattern Matching

```elixir
# This doesn't work as expected
def foo(x \\ 1, y \\ 2)
def foo(x, y) when is_integer(x), do: x + y

# Elixir creates: foo/0, foo/1, foo/2
# But guards only apply to the last clause
```
