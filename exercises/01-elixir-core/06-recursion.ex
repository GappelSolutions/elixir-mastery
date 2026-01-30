# Recursion Exercises
# Run: elixir exercises/01-elixir-core/06-recursion.ex

# =============================================================================
# Exercise 1: Flatten
# =============================================================================
# Flatten nested lists
# flatten([1, [2, [3, 4]], 5]) => [1, 2, 3, 4, 5]

defmodule Exercise1 do
  def flatten(_list) do
    :todo
  end
end

# =============================================================================
# Exercise 2: Quick Sort
# =============================================================================
# Implement quicksort using recursion

defmodule Exercise2 do
  def sort([]), do: []

  def sort([pivot | rest]) do
    # Partition into smaller/larger, recursively sort, combine
    :todo
  end
end

# =============================================================================
# Exercise 3: Permutations
# =============================================================================
# Generate all permutations of a list
# permutations([1, 2, 3]) =>
#   [[1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,1,2], [3,2,1]]

defmodule Exercise3 do
  def permutations(_list) do
    :todo
  end
end

# =============================================================================
# Exercise 4: Balanced Parentheses
# =============================================================================
# Check if parentheses are balanced and return max depth
# parse("(()())") => {:ok, 2}
# parse("(()") => {:error, :unmatched}
# parse("())") => {:error, :unmatched}

defmodule Exercise4 do
  def parse(_string) do
    :todo
  end
end

# =============================================================================
# Exercise 5: Path Finding
# =============================================================================
# Find path in a graph (adjacency list)
# graph = %{a: [:b, :c], b: [:d], c: [:d], d: []}
# find_path(graph, :a, :d) => {:ok, [:a, :b, :d]} or {:ok, [:a, :c, :d]}

defmodule Exercise5 do
  def find_path(_graph, _start, _finish) do
    # Handle cycles!
    :todo
  end
end

# =============================================================================
# Tests
# =============================================================================

ExUnit.start(auto_run: false)

defmodule RecursionTest do
  use ExUnit.Case

  describe "Exercise 1 - flatten" do
    test "flattens nested lists" do
      assert Exercise1.flatten([1, [2, [3, 4]], 5]) == [1, 2, 3, 4, 5]
    end

    test "handles empty list" do
      assert Exercise1.flatten([]) == []
    end

    test "handles flat list" do
      assert Exercise1.flatten([1, 2, 3]) == [1, 2, 3]
    end

    test "handles deeply nested" do
      assert Exercise1.flatten([[[[[1]]]]]) == [1]
    end
  end

  describe "Exercise 2 - quicksort" do
    test "sorts empty list" do
      assert Exercise2.sort([]) == []
    end

    test "sorts single element" do
      assert Exercise2.sort([1]) == [1]
    end

    test "sorts list" do
      assert Exercise2.sort([3, 1, 4, 1, 5, 9, 2, 6]) == [1, 1, 2, 3, 4, 5, 6, 9]
    end

    test "handles already sorted" do
      assert Exercise2.sort([1, 2, 3]) == [1, 2, 3]
    end

    test "handles reverse sorted" do
      assert Exercise2.sort([3, 2, 1]) == [1, 2, 3]
    end
  end

  describe "Exercise 3 - permutations" do
    test "empty list has one permutation" do
      assert Exercise3.permutations([]) == [[]]
    end

    test "single element" do
      assert Exercise3.permutations([1]) == [[1]]
    end

    test "two elements" do
      result = Exercise3.permutations([1, 2])
      assert Enum.sort(result) == [[1, 2], [2, 1]]
    end

    test "three elements" do
      result = Exercise3.permutations([1, 2, 3])
      assert length(result) == 6
      assert [1, 2, 3] in result
      assert [3, 2, 1] in result
    end
  end

  describe "Exercise 4 - balanced parens" do
    test "balanced simple" do
      assert Exercise4.parse("()") == {:ok, 1}
    end

    test "balanced nested" do
      assert Exercise4.parse("(())") == {:ok, 2}
    end

    test "balanced complex" do
      assert Exercise4.parse("(()())") == {:ok, 2}
    end

    test "unmatched open" do
      assert Exercise4.parse("(()") == {:error, :unmatched}
    end

    test "unmatched close" do
      assert Exercise4.parse("())") == {:error, :unmatched}
    end

    test "empty string" do
      assert Exercise4.parse("") == {:ok, 0}
    end
  end

  describe "Exercise 5 - path finding" do
    test "finds direct path" do
      graph = %{a: [:b], b: []}
      assert Exercise5.find_path(graph, :a, :b) == {:ok, [:a, :b]}
    end

    test "finds indirect path" do
      graph = %{a: [:b, :c], b: [:d], c: [:d], d: []}
      {:ok, path} = Exercise5.find_path(graph, :a, :d)
      assert hd(path) == :a
      assert List.last(path) == :d
    end

    test "returns error when no path" do
      graph = %{a: [:b], b: [], c: []}
      assert Exercise5.find_path(graph, :a, :c) == {:error, :no_path}
    end

    test "handles cycles" do
      graph = %{a: [:b], b: [:a, :c], c: []}
      assert {:ok, _} = Exercise5.find_path(graph, :a, :c)
    end
  end
end

ExUnit.run()
