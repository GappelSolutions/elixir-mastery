# Functions Exercises
# Run: elixir exercises/01-elixir-core/03-functions.ex

# =============================================================================
# Exercise 1: Function Composition (pipe/2)
# =============================================================================
# Implement pipe/2 that takes a value and list of functions
# pipe(5, [&(&1 + 1), &(&1 * 2), &Integer.to_string/1]) => "12"

defmodule Exercise1 do
  def pipe(_value, _functions) do
    :todo
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
  def curry(_func) do
    :todo
  end
end

# =============================================================================
# Exercise 3: Memoization
# =============================================================================
# Implement a memoized fibonacci using an Agent for cache
# fib(40) should be fast on repeated calls

defmodule Exercise3 do
  def start_cache do
    Agent.start_link(fn -> %{0 => 0, 1 => 1} end, name: :fib_cache)
  end

  def fib(_n) do
    # Check cache, compute if missing, store result
    :todo
  end

  def stop_cache do
    Agent.stop(:fib_cache)
  end
end

# =============================================================================
# Exercise 4: Retry Logic
# =============================================================================
# Implement retry/3 that retries a function n times on failure
# retry(fn -> might_fail() end, 3, 100)
# Tries up to 3 times, waiting 100ms between attempts

defmodule Exercise4 do
  def retry(_func, _attempts, _delay_ms) do
    # Return {:ok, result} or {:error, last_error}
    :todo
  end
end

# =============================================================================
# Exercise 5: Pipeline Builder
# =============================================================================
# Build a composable pipeline that can be executed later
# pipeline = Pipeline.new()
#   |> Pipeline.add(&String.trim/1)
#   |> Pipeline.add(&String.upcase/1)
# Pipeline.run(pipeline, "  hello  ") => "HELLO"

defmodule Pipeline do
  defstruct functions: []

  def new, do: %Pipeline{}

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

ExUnit.start(auto_run: false)

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

  describe "Exercise 3 - memoized fib" do
    setup do
      Exercise3.start_cache()
      on_exit(fn -> Exercise3.stop_cache() end)
      :ok
    end

    test "computes fibonacci correctly" do
      assert Exercise3.fib(0) == 0
      assert Exercise3.fib(1) == 1
      assert Exercise3.fib(10) == 55
    end

    test "handles larger numbers efficiently" do
      # Should complete quickly due to memoization
      assert Exercise3.fib(35) == 9_227_465
    end
  end

  describe "Exercise 4 - retry" do
    test "returns result on success" do
      result = Exercise4.retry(fn -> {:ok, 42} end, 3, 10)
      assert result == {:ok, 42}
    end

    test "retries on failure" do
      # Use process dictionary to track attempts
      Process.put(:attempt, 0)
      func = fn ->
        attempt = Process.get(:attempt) + 1
        Process.put(:attempt, attempt)
        if attempt < 3, do: {:error, :failed}, else: {:ok, :success}
      end

      assert Exercise4.retry(func, 3, 10) == {:ok, :success}
      assert Process.get(:attempt) == 3
    end

    test "returns error after all attempts exhausted" do
      result = Exercise4.retry(fn -> {:error, :always_fails} end, 3, 10)
      assert result == {:error, :always_fails}
    end
  end

  describe "Exercise 5 - Pipeline" do
    test "builds and runs pipeline" do
      result =
        Pipeline.new()
        |> Pipeline.add(&String.trim/1)
        |> Pipeline.add(&String.upcase/1)
        |> Pipeline.run("  hello  ")

      assert result == "HELLO"
    end

    test "empty pipeline returns input" do
      assert Pipeline.run(Pipeline.new(), "test") == "test"
    end
  end
end

ExUnit.run()
