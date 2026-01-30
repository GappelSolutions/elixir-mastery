# Data Types

**Usefulness: 10/10** - Every variable is one of these.

## Immutability First

All data in Elixir is immutable. "Updating" creates new data.

```elixir
list = [1, 2, 3]
List.delete(list, 2)  # Returns [1, 3]
list  # Still [1, 2, 3]

# If you want the result, bind it
list = List.delete(list, 2)  # Rebinding, not mutation
```

---

## Atoms

Named constants. The name IS the value.

```elixir
:ok
:error
:my_atom
:"atom with spaces"

# Booleans are atoms
true == :true   # true
false == :false # true
nil == :nil     # true

# Module names are atoms
Enum == :"Elixir.Enum"  # true
```

**Use for**: Status codes, options, keys, tags, finite sets of values.

```elixir
{:ok, result}
{:error, :not_found}
[method: :get, headers: []]
```

**Warning**: Atoms are never garbage collected. Don't create them dynamically from user input.

```elixir
# BAD - potential atom table exhaustion
String.to_atom(user_input)

# GOOD - use existing atoms only
String.to_existing_atom(user_input)
```

---

## Tuples

Fixed-size containers. Fast random access.

```elixir
{:ok, "data"}
{1, 2, 3}
{:user, "Alice", 30}

# Access by index (0-based)
elem({:a, :b, :c}, 1)  # :b

# "Update" (creates new tuple)
put_elem({:a, :b, :c}, 1, :x)  # {:a, :x, :c}

# Size
tuple_size({1, 2, 3})  # 3
```

**Use for**:
- Return values: `{:ok, result}`, `{:error, reason}`
- Small fixed collections
- Multiple return values

**Don't use for**: Collections that grow/shrink (use lists).

---

## Lists

Linked lists. Fast prepend, slow random access.

```elixir
[1, 2, 3]
["a", "b", "c"]
[1, :atom, "string"]  # Mixed types OK

# Prepend (O(1) - very fast)
[0 | [1, 2, 3]]  # [0, 1, 2, 3]

# Append (O(n) - avoid if possible)
[1, 2, 3] ++ [4, 5]  # [1, 2, 3, 4, 5]

# Head and tail
hd([1, 2, 3])  # 1
tl([1, 2, 3])  # [2, 3]

# Length (O(n) - must traverse)
length([1, 2, 3])  # 3
```

### Keyword Lists

Lists of 2-tuples with atom keys. Order preserved, duplicates allowed.

```elixir
[name: "Alice", age: 30]
# Same as: [{:name, "Alice"}, {:age, 30}]

# Common for options
String.split("a,b,c", ",", trim: true)

# Access
opts = [name: "Alice", debug: true]
opts[:name]  # "Alice"
opts[:missing]  # nil

Keyword.get(opts, :name)  # "Alice"
Keyword.get(opts, :missing, "default")  # "default"

# Duplicate keys
[a: 1, a: 2][:a]  # 1 (first match)
Keyword.get_values([a: 1, a: 2], :a)  # [1, 2]
```

**Use for**: Optional function arguments, DSLs, configs where order matters.

---

## Maps

Key-value store. Any key type. Fast access.

```elixir
%{name: "Alice", age: 30}
%{"string_key" => 1, :atom_key => 2}
%{1 => "one", 2 => "two"}

# Access (atom keys only)
user = %{name: "Alice", age: 30}
user.name  # "Alice"
user.missing  # KeyError!

# Access (any key, returns nil if missing)
user[:name]  # "Alice"
user[:missing]  # nil

Map.get(user, :name)  # "Alice"
Map.get(user, :missing, "default")  # "default"

# "Update" (creates new map)
%{user | age: 31}  # %{name: "Alice", age: 31}
# Note: key must exist for update syntax

Map.put(user, :city, "NYC")  # Adds new key
Map.delete(user, :age)  # Removes key
```

### Map vs Keyword List

| Feature | Map | Keyword List |
|---------|-----|--------------|
| Key types | Any | Atoms only |
| Duplicate keys | No | Yes |
| Order | Not guaranteed | Preserved |
| Access | O(log n) | O(n) |
| Pattern match | Partial | Full |

**Use maps for**: Data storage, JSON-like structures, when you need fast lookup.
**Use keyword lists for**: Optional arguments, when order or duplicates matter.

---

## Structs

Maps with compile-time guarantees.

```elixir
defmodule User do
  defstruct [:name, :email, age: 0]  # age has default
end

# Create
%User{name: "Alice", email: "a@b.com"}
# %User{name: "Alice", email: "a@b.com", age: 0}

# Missing required field
%User{name: "Alice"}
# %User{name: "Alice", email: nil, age: 0}

# Unknown field = compile error
%User{unknown: "value"}  # CompileError!

# Pattern matching
def process(%User{name: name, age: age}) when age >= 18 do
  "Adult: #{name}"
end

# Update syntax works
user = %User{name: "Alice", email: "a@b.com"}
%{user | age: 25}
```

### Enforcing Required Fields

```elixir
defmodule User do
  @enforce_keys [:name, :email]
  defstruct [:name, :email, age: 0]
end

%User{}  # ArgumentError: :name and :email are required
%User{name: "Alice", email: "a@b.com"}  # Works
```

### Struct Introspection

```elixir
user = %User{name: "Alice", email: "a@b.com"}

user.__struct__  # User
Map.keys(user)   # [:__struct__, :age, :email, :name]

# Struct is a map under the hood
is_map(user)  # true
%{name: name} = user  # Pattern matching works
```

---

## Binaries and Strings

Strings are UTF-8 binaries.

```elixir
"hello"
<<104, 101, 108, 108, 111>>  # Same as "hello"

# String operations
String.length("héllo")  # 5 (characters)
byte_size("héllo")      # 6 (bytes, é is 2 bytes)

# Concatenation
"hello" <> " " <> "world"  # "hello world"

# Interpolation
name = "Alice"
"Hello, #{name}!"  # "Hello, Alice!"

# Multiline
"""
This is a
multiline string
"""
```

### Charlists (Legacy)

```elixir
'hello'  # [104, 101, 108, 108, 111]
# NOT the same as "hello"

# Conversion
to_string('hello')    # "hello"
to_charlist("hello")  # 'hello'
```

**Always use double quotes** unless interfacing with Erlang.

### Binary Pattern Matching

```elixir
<<a, b, c>> = <<1, 2, 3>>
# a = 1, b = 2, c = 3

<<head::binary-size(2), rest::binary>> = "hello"
# head = "he", rest = "llo"

<<x::16-big>> = <<1, 0>>
# x = 256

# Bits
<<a::1, b::1, c::6>> = <<0b11000000>>
# a = 1, b = 1, c = 0
```

---

## Sigils

Shortcuts for creating data.

```elixir
~s(string with "quotes")     # "string with \"quotes\""
~S(no #{interpolation})      # "no \#{interpolation}"

~c(charlist)                 # 'charlist'
~C(no interpolation)         # 'no interpolation'

~w(list of words)            # ["list", "of", "words"]
~W(no #{interpolation})      # ["no", "\#{interpolation}"]
~w(atoms as words)a          # [:atoms, :as, :words]

~r/regex pattern/            # Regex
~R/no interpolation/         # Regex without interpolation

~D[2024-01-15]               # Date
~T[14:30:00]                 # Time
~U[2024-01-15 14:30:00Z]     # DateTime (UTC)
~N[2024-01-15 14:30:00]      # NaiveDateTime
```

---

## Ranges

```elixir
1..10
1..10//2  # Step of 2: 1, 3, 5, 7, 9

Enum.to_list(1..5)      # [1, 2, 3, 4, 5]
Enum.to_list(5..1//-1)  # [5, 4, 3, 2, 1]

5 in 1..10  # true
```

---

## Special Values

```elixir
nil   # Absence of value (same as :nil)
true  # Boolean true (same as :true)
false # Boolean false (same as :false)

# Only nil and false are falsy
!nil    # true
!false  # true
!0      # false (0 is truthy!)
!""     # false (empty string is truthy!)
![]     # false (empty list is truthy!)
```

---

## Exercises

### Exercise 1: Data Structure Selection
For each scenario, choose the best data structure and explain why:

1. Storing HTTP response with status code and body
2. Configuration options for a function
3. Collection of 10,000 users for lookup by ID
4. RGB color values
5. Queue of tasks to process

### Exercise 2: Struct Design
```elixir
# Design a struct for a blog post with:
# - Required: title, content, author_id
# - Optional: published_at, tags (default empty list)
# - Add a function to check if it's published

defmodule BlogPost do
  # Your code here
end
```

### Exercise 3: Binary Parsing
```elixir
# Parse a simple image header format:
# - 3 bytes: magic number "IMG"
# - 2 bytes: width (big endian)
# - 2 bytes: height (big endian)
# - 1 byte: color depth (bits per pixel)
# - Rest: pixel data

defmodule ImageParser do
  def parse(binary) do
    # Return: {:ok, %{width: w, height: h, depth: d, pixels: data}}
    # or {:error, :invalid_format}
  end
end
```

### Exercise 4: Map Manipulation
```elixir
# Implement a function that deeply merges two maps
# deep_merge(%{a: %{b: 1}}, %{a: %{c: 2}})
# => %{a: %{b: 1, c: 2}}

defmodule DeepMerge do
  def merge(map1, map2) do
    # Your code here
  end
end
```

### Exercise 5: Keyword List Operations
```elixir
# Build a query string from keyword list
# to_query_string([name: "Alice", age: 30, name: "Bob"])
# => "name=Alice&age=30&name=Bob"

defmodule QueryString do
  def to_query_string(opts) do
    # Your code here
  end
end
```

---

## Common Pitfalls

### 1. Confusing Syntax

```elixir
# Map with atom keys (shorthand)
%{name: "Alice"}

# Map with string keys
%{"name" => "Alice"}

# These are DIFFERENT maps!
%{name: "Alice"} == %{"name" => "Alice"}  # false
```

### 2. List Performance

```elixir
# BAD - appending in a loop is O(n²)
Enum.reduce(1..1000, [], fn x, acc -> acc ++ [x] end)

# GOOD - prepend then reverse is O(n)
1..1000
|> Enum.reduce([], fn x, acc -> [x | acc] end)
|> Enum.reverse()
```

### 3. Struct Update Requires Existing Key

```elixir
user = %User{name: "Alice", email: "a@b.com"}

# This crashes - :city doesn't exist in User struct
%{user | city: "NYC"}  # KeyError!

# For new fields, use Map.put (but you lose struct type)
Map.put(user, :city, "NYC")  # Returns a plain map
```
