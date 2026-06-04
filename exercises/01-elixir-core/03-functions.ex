# Functions Exercises
# Run: elixir exercises/01-elixir-core/03-functions.ex

# =============================================================================
# Exercise 1: Function Composition (pipe/2)
# =============================================================================
# Implement pipe/2 that takes a value and list of functions
# pipe(5, [&(&1 + 1), &(&1 * 2), &Integer.to_string/1]) => "12"

defmodule Exercise1 do
  def pipe(value, []), do: value

  def pipe(value, [head | tail]) do
    pipe(head.(value), tail)
  end
end

# =============================================================================
# Exercise 2: Currying
# =============================================================================
# Implement curry/1 that converts a 2-arg function to curried form
# add = fn a, b -> a + b end
# curried = curry(add)
# curried.(1).(2) => 3

defmodule Exercise2 do
  def curry(func) do
    fn a ->
      fn b ->
        func.(a, b)
      end
    end
  end
end

# =============================================================================
# Exercise 3: Pipeline Builder
# =============================================================================
# Build a composable pipeline that can be executed later
# pipeline = Pipeline.new()
#   |> Pipeline.add(&String.trim/1)
#   |> Pipeline.add(&String.upcase/1)
# Pipeline.run(pipeline, "  hello  ") => "HELLO"

defmodule Exercise3 do
  defstruct functions: []

  def new, do: %Exercise3{}

  def add(_pipeline, _func) do
    :todo
  end

  def run(_pipeline, _value) do
    :todo
  end
end

# =============================================================================
# Tests
# =============================================================================

unless System.get_env("ELX_EXTERNAL_RUNNER"), do: ExUnit.start(autorun: false)

defmodule FunctionsTest do
  use ExUnit.Case

  describe "Exercise 1 - pipe" do
    test "applies functions in order" do
      result = Exercise1.pipe(5, [&(&1 + 1), &(&1 * 2)])
      assert result == 12
    end

    test "handles empty function list" do
      assert Exercise1.pipe(5, []) == 5
    end

    test "works with named functions" do
      result = Exercise1.pipe("  hello  ", [&String.trim/1, &String.upcase/1])
      assert result == "HELLO"
    end
  end

  describe "Exercise 2 - curry" do
    test "curries a 2-arg function" do
      add = fn a, b -> a + b end
      curried = Exercise2.curry(add)
      assert curried.(1).(2) == 3
    end

    test "partial application works" do
      multiply = fn a, b -> a * b end
      double = Exercise2.curry(multiply).(2)
      assert double.(5) == 10
    end
  end

  describe "Exercise 3 - Pipeline" do
    test "builds and runs pipeline" do
      result =
        Exercise3.new()
        |> Exercise3.add(&String.trim/1)
        |> Exercise3.add(&String.upcase/1)
        |> Exercise3.run("  hello  ")

      assert result == "HELLO"
    end

    test "empty pipeline returns input" do
      assert Exercise3.run(Exercise3.new(), "test") == "test"
    end
  end
end

unless System.get_env("ELX_EXTERNAL_RUNNER"), do: ExUnit.run()
