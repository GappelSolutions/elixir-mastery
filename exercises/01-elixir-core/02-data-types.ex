# Data Types Exercises
# Run: elixir exercises/01-elixir-core/02-data-types.ex

# =============================================================================
# Exercise 1: Data Structure Selection
# =============================================================================
# For each scenario, implement a function that returns the best data structure
# and a brief atom explaining why.

defmodule Exercise1 do
  # HTTP response with status code and body
  # Return: {:tuple, :reason} or {:map, :reason} etc.
  def http_response do
    # What's the best structure for {:ok, 200, "body"}?
    :todo
  end

  # Configuration options for a function
  def config_options do
    # Best for [timeout: 5000, retries: 3]?
    :todo
  end

  # Collection of 10,000 users for lookup by ID
  def user_collection do
    # Best for frequent lookups?
    :todo
  end

  # RGB color values (always exactly 3 integers 0-255)
  def rgb_color do
    :todo
  end

  # Queue of tasks to process (FIFO)
  def task_queue do
    :todo
  end
end

# =============================================================================
# Exercise 2: Struct Design
# =============================================================================
# Design a struct for a blog post with:
# - Required: title, content, author_id
# - Optional: published_at (default nil), tags (default empty list)
# - Add a function to check if it's published

defmodule BlogPost do
  # Define struct with @enforce_keys

  def published?(_post) do
    :todo
  end
end

# =============================================================================
# Exercise 3: Binary Parsing
# =============================================================================
# Parse a simple image header format:
# - 3 bytes: magic number "IMG"
# - 2 bytes: width (big endian)
# - 2 bytes: height (big endian)
# - 1 byte: color depth (bits per pixel)
# - Rest: pixel data

defmodule Exercise3 do
  def parse(_binary) do
    # Return: {:ok, %{width: w, height: h, depth: d, pixels: data}}
    # or {:error, :invalid_format}
    :todo
  end
end

# =============================================================================
# Exercise 4: Deep Merge
# =============================================================================
# Implement a function that deeply merges two maps
# deep_merge(%{a: %{b: 1}}, %{a: %{c: 2}}) => %{a: %{b: 1, c: 2}}

defmodule Exercise4 do
  def deep_merge(_map1, _map2) do
    :todo
  end
end

# =============================================================================
# Exercise 5: Query String Builder
# =============================================================================
# Build a query string from keyword list
# to_query_string([name: "Alice", age: 30, name: "Bob"])
# => "name=Alice&age=30&name=Bob"

defmodule Exercise5 do
  def to_query_string(_opts) do
    :todo
  end
end

# =============================================================================
# Tests
# =============================================================================

ExUnit.start(auto_run: false)

defmodule DataTypesTest do
  use ExUnit.Case

  describe "Exercise 2 - BlogPost struct" do
    test "requires title, content, author_id" do
      assert_raise ArgumentError, fn ->
        struct!(BlogPost, %{})
      end
    end

    test "has default tags as empty list" do
      post = struct!(BlogPost, %{title: "Hi", content: "...", author_id: 1})
      assert post.tags == []
    end

    test "published? returns false when published_at is nil" do
      post = struct!(BlogPost, %{title: "Hi", content: "...", author_id: 1})
      refute BlogPost.published?(post)
    end

    test "published? returns true when published_at is set" do
      post = struct!(BlogPost, %{
        title: "Hi",
        content: "...",
        author_id: 1,
        published_at: DateTime.utc_now()
      })
      assert BlogPost.published?(post)
    end
  end

  describe "Exercise 3 - Image parser" do
    test "parses valid image header" do
      binary = <<"IMG", 100::16-big, 200::16-big, 24, "pixels">>
      assert {:ok, %{width: 100, height: 200, depth: 24, pixels: "pixels"}} =
        Exercise3.parse(binary)
    end

    test "returns error for invalid magic" do
      binary = <<"PNG", 100::16-big, 200::16-big, 24>>
      assert {:error, :invalid_format} = Exercise3.parse(binary)
    end
  end

  describe "Exercise 4 - Deep merge" do
    test "merges flat maps" do
      assert Exercise4.deep_merge(%{a: 1}, %{b: 2}) == %{a: 1, b: 2}
    end

    test "merges nested maps" do
      result = Exercise4.deep_merge(%{a: %{b: 1}}, %{a: %{c: 2}})
      assert result == %{a: %{b: 1, c: 2}}
    end

    test "right side wins for non-map values" do
      assert Exercise4.deep_merge(%{a: 1}, %{a: 2}) == %{a: 2}
    end

    test "handles deeply nested" do
      m1 = %{a: %{b: %{c: 1}}}
      m2 = %{a: %{b: %{d: 2}}}
      assert Exercise4.deep_merge(m1, m2) == %{a: %{b: %{c: 1, d: 2}}}
    end
  end

  describe "Exercise 5 - Query string" do
    test "builds simple query string" do
      assert Exercise5.to_query_string([name: "Alice"]) == "name=Alice"
    end

    test "handles multiple params" do
      assert Exercise5.to_query_string([name: "Alice", age: 30]) == "name=Alice&age=30"
    end

    test "handles duplicate keys" do
      result = Exercise5.to_query_string([name: "Alice", name: "Bob"])
      assert result == "name=Alice&name=Bob"
    end

    test "handles empty list" do
      assert Exercise5.to_query_string([]) == ""
    end
  end
end

ExUnit.run()
