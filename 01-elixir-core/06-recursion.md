# Recursion

**Usefulness: 8/10** - No loops in Elixir. Recursion is the loop.

## Basic Recursion

```elixir
defmodule Recursion do
  def countdown(0), do: IO.puts("Blastoff!")
  def countdown(n) when n > 0 do
    IO.puts(n)
    countdown(n - 1)
  end
end

Recursion.countdown(5)
# 5
# 4
# 3
# 2
# 1
# Blastoff!
```

## Tail Call Optimization

When the recursive call is the LAST operation, Elixir optimizes to a loop (no stack growth).

```elixir
# NOT tail recursive - multiplication happens AFTER recursive call
def factorial(0), do: 1
def factorial(n), do: n * factorial(n - 1)

# Tail recursive - recursive call IS the last operation
def factorial(n), do: factorial(n, 1)

defp factorial(0, acc), do: acc
defp factorial(n, acc), do: factorial(n - 1, n * acc)
```

### Identifying Tail Position

```elixir
# NOT tail recursive - addition after call
def sum([]), do: 0
def sum([h | t]), do: h + sum(t)

# Tail recursive
def sum(list), do: sum(list, 0)
defp sum([], acc), do: acc
defp sum([h | t], acc), do: sum(t, h + acc)
```

## Common Recursive Patterns

### List Processing

```elixir
defmodule MyList do
  # Map
  def map([], _func), do: []
  def map([h | t], func), do: [func.(h) | map(t, func)]

  # Filter
  def filter([], _pred), do: []
  def filter([h | t], pred) do
    if pred.(h) do
      [h | filter(t, pred)]
    else
      filter(t, pred)
    end
  end

  # Reduce (tail recursive)
  def reduce([], acc, _func), do: acc
  def reduce([h | t], acc, func), do: reduce(t, func.(h, acc), func)

  # Reverse (tail recursive)
  def reverse(list), do: reverse(list, [])
  defp reverse([], acc), do: acc
  defp reverse([h | t], acc), do: reverse(t, [h | acc])

  # Length (tail recursive)
  def length(list), do: length(list, 0)
  defp length([], acc), do: acc
  defp length([_ | t], acc), do: length(t, acc + 1)
end
```

### Tree Traversal

```elixir
defmodule Tree do
  # {:node, value, left, right} or :empty

  def sum(:empty), do: 0
  def sum({:node, value, left, right}) do
    value + sum(left) + sum(right)
  end

  def depth(:empty), do: 0
  def depth({:node, _, left, right}) do
    1 + max(depth(left), depth(right))
  end

  def map(:empty, _func), do: :empty
  def map({:node, value, left, right}, func) do
    {:node, func.(value), map(left, func), map(right, func)}
  end
end
```

### Binary Search

```elixir
defmodule Search do
  def binary_search(list, target) do
    do_search(list, target, 0, length(list) - 1)
  end

  defp do_search(_list, _target, low, high) when low > high do
    :not_found
  end

  defp do_search(list, target, low, high) do
    mid = div(low + high, 2)
    value = Enum.at(list, mid)

    cond do
      value == target -> {:found, mid}
      value > target -> do_search(list, target, low, mid - 1)
      value < target -> do_search(list, target, mid + 1, high)
    end
  end
end
```

## When to Use Enum Instead

```elixir
# Usually prefer Enum for standard operations
Enum.map(list, &(&1 * 2))
Enum.filter(list, &(&1 > 0))
Enum.reduce(list, 0, &+/2)

# Use recursion when:
# - Processing multiple lists in lockstep
# - Complex termination conditions
# - Building non-list results
# - Performance-critical inner loops
```

## Mutual Recursion

Functions that call each other.

```elixir
defmodule EvenOdd do
  def even?(0), do: true
  def even?(n), do: odd?(n - 1)

  def odd?(0), do: false
  def odd?(n), do: even?(n - 1)
end
```

## Infinite Streams with Recursion

```elixir
defmodule InfiniteStream do
  def naturals(n \\ 0) do
    Stream.unfold(n, fn x -> {x, x + 1} end)
  end

  def fibonacci do
    Stream.unfold({0, 1}, fn {a, b} -> {a, {b, a + b}} end)
  end
end

InfiniteStream.naturals() |> Enum.take(5)  # [0, 1, 2, 3, 4]
InfiniteStream.fibonacci() |> Enum.take(8)  # [0, 1, 1, 2, 3, 5, 8, 13]
```

---

## Exercises

### Exercise 1: Flatten
```elixir
# Flatten nested lists
# flatten([1, [2, [3, 4]], 5]) => [1, 2, 3, 4, 5]

defmodule Flatten do
  def flatten(list) do
    # Your code here
  end
end
```

### Exercise 2: Quick Sort
```elixir
defmodule QuickSort do
  def sort([]), do: []
  def sort([pivot | rest]) do
    # Partition into smaller/larger, recursively sort, combine
  end
end
```

### Exercise 3: Permutations
```elixir
# Generate all permutations
# permutations([1, 2, 3]) =>
#   [[1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,1,2], [3,2,1]]

defmodule Permutations do
  def generate(list) do
    # Your code here
  end
end
```

### Exercise 4: Parser Combinators
```elixir
# Build a simple parser using recursion
# Parse nested parentheses: "(()())" => {:ok, 3} (depth 3)
# "(()(" => {:error, :unmatched}

defmodule ParenParser do
  def parse(string) do
    # Your code here
  end
end
```

### Exercise 5: Path Finding
```elixir
# Find path in a graph (adjacency list)
# graph = %{a: [:b, :c], b: [:d], c: [:d], d: []}
# find_path(graph, :a, :d) => [:a, :b, :d] or [:a, :c, :d]

defmodule PathFinder do
  def find_path(graph, start, finish) do
    # Your code here (handle cycles!)
  end
end
```

---

## Performance Considerations

### Stack Depth

Non-tail-recursive functions consume stack space per call.

```elixir
# Will crash with large input (stack overflow)
def bad_sum([]), do: 0
def bad_sum([h | t]), do: h + bad_sum(t)

bad_sum(Enum.to_list(1..1_000_000))  # SystemLimitError

# Tail recursive - works fine
def good_sum(list), do: good_sum(list, 0)
defp good_sum([], acc), do: acc
defp good_sum([h | t], acc), do: good_sum(t, h + acc)

good_sum(Enum.to_list(1..1_000_000))  # 500000500000
```

### Body-Recursive vs Tail-Recursive

Sometimes body-recursive is actually faster due to less accumulator manipulation:

```elixir
# Body recursive (might be faster for small lists)
def map1([], _f), do: []
def map1([h | t], f), do: [f.(h) | map1(t, f)]

# Tail recursive (guaranteed constant stack, but builds reversed)
def map2(list, f), do: map2(list, f, [])
defp map2([], _f, acc), do: Enum.reverse(acc)
defp map2([h | t], f, acc), do: map2(t, f, [f.(h) | acc])
```

Benchmark for your use case. The Enum module uses optimized implementations.
