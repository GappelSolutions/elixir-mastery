# Pattern Matching Exercises
# Run: elixir exercises/01-elixir-core/01-pattern-matching.ex
# Review: /elixir-review exercises/01-elixir-core/01-pattern-matching.ex

# =============================================================================
# Exercise 1: Basic Destructuring
# =============================================================================
# Extract coordinates from these structures:
# - point_2d = {3, 4}         -> x = 3, y = 4
# - point_3d = {1, 2, 3}      -> x = 1, y = 2, z = 3
# - response = {:ok, %{x: 10, y: 20}} -> x = 10, y = 20

defmodule Exercise1 do
  def extract_2d({x, y}) do
    {x, y}
  end

  def extract_3d({x, y, z}) do
    {x, y, z}
  end

  def extract_from_response({:ok, %{x: x, y: y}}) do
    {x, y}
  end
end

# =============================================================================
# Exercise 2: List Patterns
# =============================================================================
# Classify lists by their length:
# - []        -> :empty
# - [x]       -> :single
# - [x, y]    -> :pair
# - [x, y, z] -> :triple
# - longer    -> :many

defmodule Exercise2 do
  def classify([]), do: :empty
  def classify([_]), do: :single
  def classify([_, _]), do: :pair
  def classify([_, _, _]), do: :triple
  def classify([_, _, _ | _]), do: :many
end

# =============================================================================
# Exercise 3: FizzBuzz with Pattern Matching
# =============================================================================
# Classic FizzBuzz but using pattern matching on {rem(n, 3), rem(n, 5)}
# No if statements allowed!

defmodule Exercise3 do
  def fizzbuzz(n) do
    case {rem(n, 3), rem(n, 5)} do
      {0, 0} -> "FizzBuzz"
      {0, _} -> "Fizz"
      {_, 0} -> "Buzz"
      _ -> Integer.to_string(n)
    end
  end

  def run(max) do
    1..max
    |> Enum.map(&fizzbuzz/1)
    |> Enum.join(", ")
    |> IO.puts()
  end
end

# =============================================================================
# Exercise 4: Recursive Sum
# =============================================================================
# Sum all numbers in a nested list structure
# sum([1, [2, 3], [[4]]]) should return 10

defmodule Exercise4 do
  def sum([]), do: 0
  def sum([head | tail]) when is_list(head), do: sum(head) + sum(tail)
  def sum([head | tail]), do: head + sum(tail)
end

# =============================================================================
# Exercise 5: Parse Key-Value Strings
# =============================================================================
# Parse "key=value" strings
# "name=Alice" -> {:ok, {"name", "Alice"}}
# ""           -> {:error, :empty}
# "noequals"   -> {:error, :invalid_format}
# "a=b=c"      -> {:ok, {"a", "b=c"}}

defmodule Exercise5 do
  def parse(""), do: {:error, :empty}

  def parse(string) do
    case String.split(string, "=", parts: 2) do
      [key, value] -> {:ok, {key, value}}
      [_] -> {:error, :invalid_format}
    end
  end
end

# =============================================================================
# Exercise 6: Binary Parser
# =============================================================================
# Parse a simple binary format:
# - First byte: message type (1 = text, 2 = binary, 3 = ping)
# - Next 2 bytes: payload length (big endian)
# - Rest: payload of that length
#
# Return {:ok, %{type: atom, payload: binary}} or {:error, reason}

defmodule Exercise6 do
  def parse(<<type_binary::8, payload_length::16, payload::binary-size(payload_length)>>),
    do: {:ok, %{type: get_type(type_binary), payload: payload}}

  def parse(_), do: {:error, :invalid_format}

  defp get_type(1), do: :text
  defp get_type(2), do: :binary
  defp get_type(3), do: :ping
  defp get_type(_), do: :invalid_type
end

# =============================================================================
# Tests - Run to verify your solutions
# =============================================================================

# Start ExUnit if not using external runner
unless System.get_env("ELX_EXTERNAL_RUNNER"), do: ExUnit.start(auto_run: false)

defmodule PatternMatchingTest do
  use ExUnit.Case

  describe "Exercise 1 - Destructuring" do
    test "extracts 2D coordinates" do
      assert Exercise1.extract_2d({3, 4}) == {3, 4}
      assert Exercise1.extract_2d({0, 0}) == {0, 0}
    end

    test "extracts 3D coordinates" do
      assert Exercise1.extract_3d({1, 2, 3}) == {1, 2, 3}
    end

    test "extracts from response" do
      assert Exercise1.extract_from_response({:ok, %{x: 10, y: 20}}) == {10, 20}
    end
  end

  describe "Exercise 2 - List Classification" do
    test "classifies empty list" do
      assert Exercise2.classify([]) == :empty
    end

    test "classifies single element" do
      assert Exercise2.classify([1]) == :single
    end

    test "classifies pair" do
      assert Exercise2.classify([1, 2]) == :pair
    end

    test "classifies triple" do
      assert Exercise2.classify([1, 2, 3]) == :triple
    end

    test "classifies many" do
      assert Exercise2.classify([1, 2, 3, 4]) == :many
      assert Exercise2.classify([1, 2, 3, 4, 5]) == :many
    end
  end

  describe "Exercise 3 - FizzBuzz" do
    test "returns Fizz for multiples of 3" do
      assert Exercise3.fizzbuzz(3) == "Fizz"
      assert Exercise3.fizzbuzz(9) == "Fizz"
    end

    test "returns Buzz for multiples of 5" do
      assert Exercise3.fizzbuzz(5) == "Buzz"
      assert Exercise3.fizzbuzz(10) == "Buzz"
    end

    test "returns FizzBuzz for multiples of both" do
      assert Exercise3.fizzbuzz(15) == "FizzBuzz"
      assert Exercise3.fizzbuzz(30) == "FizzBuzz"
    end

    test "returns number as string otherwise" do
      assert Exercise3.fizzbuzz(1) == "1"
      assert Exercise3.fizzbuzz(7) == "7"
    end
  end

  describe "Exercise 4 - Nested Sum" do
    test "sums empty list" do
      assert Exercise4.sum([]) == 0
    end

    test "sums flat list" do
      assert Exercise4.sum([1, 2, 3]) == 6
    end

    test "sums nested list" do
      assert Exercise4.sum([1, [2, 3], [[4]]]) == 10
    end

    test "handles deeply nested" do
      assert Exercise4.sum([[[[[5]]]]]) == 5
    end
  end

  describe "Exercise 5 - Key-Value Parser" do
    test "parses valid key=value" do
      assert Exercise5.parse("name=Alice") == {:ok, {"name", "Alice"}}
    end

    test "handles empty string" do
      assert Exercise5.parse("") == {:error, :empty}
    end

    test "handles missing equals" do
      assert Exercise5.parse("noequals") == {:error, :invalid_format}
    end

    test "handles multiple equals" do
      assert Exercise5.parse("a=b=c") == {:ok, {"a", "b=c"}}
    end
  end

  describe "Exercise 6 - Binary Parser" do
    test "parses text message" do
      binary = <<1, 0, 5, "hello">>
      assert Exercise6.parse(binary) == {:ok, %{type: :text, payload: "hello"}}
    end

    test "parses binary message" do
      binary = <<2, 0, 3, 1, 2, 3>>
      assert Exercise6.parse(binary) == {:ok, %{type: :binary, payload: <<1, 2, 3>>}}
    end

    test "parses ping" do
      binary = <<3, 0, 0>>
      assert Exercise6.parse(binary) == {:ok, %{type: :ping, payload: <<>>}}
    end
  end
end

# Run tests if executed directly (not via external runner)
unless System.get_env("ELX_EXTERNAL_RUNNER"), do: ExUnit.run()
