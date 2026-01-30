# Control Flow

**Usefulness: 9/10** - But pattern matching replaces most of it.

## case

Pattern match against a value.

```elixir
case fetch_user(id) do
  {:ok, user} ->
    "Found #{user.name}"

  {:error, :not_found} ->
    "User not found"

  {:error, reason} ->
    "Error: #{reason}"
end
```

With guards:

```elixir
case value do
  x when is_integer(x) and x > 0 -> :positive
  x when is_integer(x) and x < 0 -> :negative
  0 -> :zero
  _ -> :not_integer
end
```

## cond

Multiple conditions (like if-elseif chain).

```elixir
cond do
  age < 13 -> :child
  age < 20 -> :teenager
  age < 65 -> :adult
  true -> :senior  # Default case
end
```

**When to use**: When conditions aren't pattern-matchable.

```elixir
cond do
  String.contains?(input, "hello") -> :greeting
  String.length(input) > 100 -> :too_long
  Regex.match?(~r/\d+/, input) -> :has_numbers
  true -> :other
end
```

## with

Chain operations that might fail. The power tool for error handling.

```elixir
with {:ok, user} <- fetch_user(id),
     {:ok, account} <- fetch_account(user.account_id),
     {:ok, balance} <- get_balance(account) do
  {:ok, "#{user.name} has $#{balance}"}
else
  {:error, :user_not_found} -> {:error, "User not found"}
  {:error, :account_locked} -> {:error, "Account is locked"}
  error -> error
end
```

### Bare Expressions in with

```elixir
with {:ok, data} <- fetch_data(),
     decoded = Jason.decode!(data),  # Bare expression, always matches
     {:ok, valid} <- validate(decoded) do
  process(valid)
end
```

### with vs case vs pipe

```elixir
# Use pipe when operations can't fail
input
|> String.trim()
|> String.downcase()
|> String.split()

# Use case for single match
case result do
  {:ok, val} -> val
  {:error, _} -> nil
end

# Use with for chained fallible operations
with {:ok, a} <- step1(),
     {:ok, b} <- step2(a),
     {:ok, c} <- step3(b) do
  {:ok, c}
end
```

## if / unless

Simple conditionals. Less common in idiomatic Elixir.

```elixir
if condition do
  "true branch"
else
  "false branch"
end

unless condition do
  "runs if condition is falsy"
end

# One-liner
if condition, do: "yes", else: "no"
```

**Prefer pattern matching when possible**:

```elixir
# Less idiomatic
def process(user) do
  if user.admin do
    admin_process(user)
  else
    standard_process(user)
  end
end

# More idiomatic
def process(%{admin: true} = user), do: admin_process(user)
def process(user), do: standard_process(user)
```

## Truthiness

Only `nil` and `false` are falsy. Everything else is truthy.

```elixir
if 0, do: "truthy"        # "truthy"
if "", do: "truthy"       # "truthy"
if [], do: "truthy"       # "truthy"
if nil, do: "x", else: "y"  # "y"
if false, do: "x", else: "y"  # "y"
```

## Boolean Operators

```elixir
# Strict - require boolean operands
true and false  # false
true or false   # true
not true        # false

# Relaxed - work with any values, return last evaluated
nil && "value"  # nil
"a" && "b"      # "b"
nil || "default"  # "default"
"a" || "b"      # "a"
!nil  # true
!"x"  # false
```

## raise / throw / exit

### raise (Exceptions)

For exceptional errors, not control flow.

```elixir
raise "Something went wrong"
raise ArgumentError, message: "Invalid argument"

# Define custom exception
defmodule MyError do
  defexception [:message, :code]
end

raise MyError, message: "Failed", code: 500
```

### try / rescue / after

```elixir
try do
  risky_operation()
rescue
  e in RuntimeError ->
    "Runtime error: #{e.message}"
  ArgumentError ->
    "Bad argument"
  e ->
    "Unknown error: #{inspect(e)}"
after
  cleanup()  # Always runs
end
```

### throw / catch

For non-local returns. Rare in practice.

```elixir
try do
  Enum.each(1..100, fn x ->
    if x == 42, do: throw(:found)
  end)
  :not_found
catch
  :found -> :found
end
```

### exit

Signal process termination.

```elixir
exit(:normal)
exit(:shutdown)
exit({:error, reason})
```

---

## Exercises

### Exercise 1: Parser with `with`
```elixir
# Parse a config string like "key=value;key2=value2"
# Return {:ok, map} or {:error, reason}

defmodule ConfigParser do
  def parse(string) do
    # Use `with` to:
    # 1. Split by semicolon
    # 2. Parse each pair
    # 3. Build map
    # Handle errors at each step
  end
end
```

### Exercise 2: Conditional Refactor
```elixir
# Refactor this to use pattern matching instead of if/else

def categorize(item) do
  if item.type == :book do
    if item.pages > 500 do
      :long_book
    else
      :short_book
    end
  else
    if item.type == :movie do
      if item.duration > 120 do
        :long_movie
      else
        :short_movie
      end
    else
      :unknown
    end
  end
end
```

### Exercise 3: Error Accumulation
```elixir
# Validate multiple fields and collect all errors
# validate(%{name: "", email: "bad", age: -1})
# => {:error, ["name is required", "invalid email", "age must be positive"]}

defmodule Validator do
  def validate(params) do
    # Your code here
    # Don't short-circuit - collect all errors
  end
end
```

### Exercise 4: Short-Circuit Search
```elixir
# Find first item matching predicate without iterating all
# Use throw/catch or recursion with early return

defmodule Search do
  def find_first(enumerable, predicate) do
    # Return {:ok, item} or :not_found
  end
end
```

---

## Anti-Patterns

### Nested case statements

```elixir
# BAD
case fetch_user(id) do
  {:ok, user} ->
    case fetch_account(user.account_id) do
      {:ok, account} ->
        case get_balance(account) do
          {:ok, balance} -> {:ok, balance}
          error -> error
        end
      error -> error
    end
  error -> error
end

# GOOD - use with
with {:ok, user} <- fetch_user(id),
     {:ok, account} <- fetch_account(user.account_id),
     {:ok, balance} <- get_balance(account) do
  {:ok, balance}
end
```

### Using exceptions for control flow

```elixir
# BAD
try do
  user = get_user!(id)  # Raises if not found
  do_something(user)
rescue
  Ecto.NoResultsError -> nil
end

# GOOD
case get_user(id) do
  {:ok, user} -> do_something(user)
  {:error, :not_found} -> nil
end
```

### Boolean flags

```elixir
# BAD
def process(data, is_admin) do
  if is_admin do
    admin_process(data)
  else
    user_process(data)
  end
end

# GOOD - use pattern matching or multiple functions
def process(data, :admin), do: admin_process(data)
def process(data, :user), do: user_process(data)
```
