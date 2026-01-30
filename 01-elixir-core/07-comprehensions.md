# Comprehensions

**Usefulness: 8/10** - Elegant iteration with filtering and transformation.

## Basic Syntax

```elixir
for x <- [1, 2, 3], do: x * 2
# [2, 4, 6]
```

## Multiple Generators

Cartesian product - every combination.

```elixir
for x <- [1, 2], y <- [:a, :b] do
  {x, y}
end
# [{1, :a}, {1, :b}, {2, :a}, {2, :b}]

# Deck of cards
suits = [:hearts, :diamonds, :clubs, :spades]
ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]

deck = for suit <- suits, rank <- ranks, do: {rank, suit}
# [{2, :hearts}, {3, :hearts}, ... {ace, :spades}]
```

## Filters

Only process matching items.

```elixir
for x <- 1..10, rem(x, 2) == 0, do: x
# [2, 4, 6, 8, 10]

# Multiple filters (all must pass)
for x <- 1..100,
    rem(x, 3) == 0,
    rem(x, 5) == 0 do
  x
end
# [15, 30, 45, 60, 75, 90]
```

## Pattern Matching in Generators

```elixir
data = [ok: 1, error: 2, ok: 3, error: 4]

for {:ok, value} <- data, do: value
# [1, 3]

users = [
  %{name: "Alice", active: true},
  %{name: "Bob", active: false},
  %{name: "Carol", active: true}
]

for %{name: name, active: true} <- users, do: name
# ["Alice", "Carol"]
```

## Into Different Collectables

```elixir
# Into a map
for {k, v} <- [a: 1, b: 2], into: %{}, do: {k, v * 2}
# %{a: 2, b: 4}

# Into a string
for c <- ~c"hello", into: "", do: <<c + 1>>
# "ifmmp"

# Into MapSet
for x <- [1, 2, 2, 3, 3, 3], into: MapSet.new(), do: x
# MapSet.new([1, 2, 3])

# Into existing collection
existing = %{z: 26}
for {k, v} <- [a: 1, b: 2], into: existing, do: {k, v}
# %{a: 1, b: 2, z: 26}
```

## Reduce with :reduce

Accumulate instead of collecting.

```elixir
for x <- 1..10, reduce: 0 do
  acc -> acc + x
end
# 55

# Count occurrences
for char <- String.graphemes("hello world"), reduce: %{} do
  acc ->
    Map.update(acc, char, 1, &(&1 + 1))
end
# %{" " => 1, "d" => 1, "e" => 1, "h" => 1, "l" => 3, ...}
```

## Uniq

Remove duplicates from result.

```elixir
for x <- [1, 2, 2, 3, 3, 3], uniq: true, do: x
# [1, 2, 3]
```

## Bitstring Generators

Iterate over binary data.

```elixir
# Parse bytes
for <<byte <- "hello">>, do: byte
# [104, 101, 108, 108, 111]

# Parse 16-bit integers
for <<value::16 <- <<0, 1, 0, 2, 0, 3>>>>, do: value
# [1, 2, 3]

# Generate binary
pixels = [{255, 0, 0}, {0, 255, 0}, {0, 0, 255}]
for {r, g, b} <- pixels, into: <<>>, do: <<r, g, b>>
# <<255, 0, 0, 0, 255, 0, 0, 0, 255>>
```

## Nested Comprehensions

```elixir
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

# Flatten and double
for row <- matrix, x <- row, do: x * 2
# [2, 4, 6, 8, 10, 12, 14, 16, 18]

# Transpose (nested comprehensions)
for i <- 0..(length(matrix) - 1) do
  for row <- matrix, do: Enum.at(row, i)
end
# [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
```

## Comprehension vs Enum

```elixir
# These are equivalent
for x <- list, x > 0, do: x * 2

list
|> Enum.filter(&(&1 > 0))
|> Enum.map(&(&1 * 2))

# Comprehensions are often cleaner for:
# - Multiple generators (cartesian product)
# - Pattern matching filters
# - Collecting into different types
# - Bitstring processing
```

---

## Exercises

### Exercise 1: Pythagorean Triples
```elixir
# Find all Pythagorean triples where a, b, c <= n
# and a² + b² = c²

defmodule Pythagorean do
  def triples(n) do
    # Your code here
    # Hint: for a <- ..., b <- ..., c <- ...
  end
end

Pythagorean.triples(20)
# [{3, 4, 5}, {5, 12, 13}, {6, 8, 10}, ...]
```

### Exercise 2: Cross Product
```elixir
# Compute dot product of two vectors
# cross([1, 2, 3], [4, 5, 6]) => 32 (1*4 + 2*5 + 3*6)

defmodule Vector do
  def dot(v1, v2) do
    # Use comprehension with reduce
  end
end
```

### Exercise 3: Word Frequency
```elixir
# Count word frequency in text
# word_freq("the quick brown fox jumps over the lazy dog")
# => %{"the" => 2, "quick" => 1, ...}

defmodule WordFreq do
  def count(text) do
    # Use comprehension with reduce
  end
end
```

### Exercise 4: Sudoku Validator
```elixir
# Check if a row/column/box contains 1-9 exactly once
# Use comprehensions to extract rows, columns, and 3x3 boxes

defmodule Sudoku do
  def valid?(grid) do
    # grid is 9x9 list of lists
  end
end
```

### Exercise 5: Image Processing
```elixir
# Convert RGB binary to grayscale
# grayscale(<<r, g, b, r, g, b, ...>>) => <<gray, gray, ...>>
# gray = 0.299*r + 0.587*g + 0.114*b

defmodule Image do
  def grayscale(rgb_binary) do
    # Use bitstring generator and into: <<>>
  end
end
```

---

## Performance

Comprehensions compile to efficient code but:

```elixir
# Multiple generators = cartesian product = can explode
for x <- 1..1000, y <- 1..1000, z <- 1..1000 do
  {x, y, z}
end
# 1 billion elements! Don't do this.

# Filters reduce early
for x <- 1..1000, x < 5, y <- 1..1000, y < 5 do
  {x, y}
end
# Only 16 elements - filters apply before next generator
```
