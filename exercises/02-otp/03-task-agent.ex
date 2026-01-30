# Task & Agent Exercises
# Run: elixir exercises/02-otp/03-task-agent.ex

# =============================================================================
# Exercise 1: Parallel HTTP Fetcher
# =============================================================================
# Fetch multiple URLs in parallel with:
# - Max 5 concurrent requests
# - 10s timeout per request
# - Return results as they complete

defmodule Exercise1 do
  def fetch_all(urls) do
    # Use Task.async_stream with max_concurrency
    # Return [{url, {:ok, body}} | {url, {:error, reason}}]
    :todo
  end

  # Mock fetch function for testing
  def fetch(url) do
    Process.sleep(Enum.random(10..100))
    if String.contains?(url, "fail") do
      {:error, :not_found}
    else
      {:ok, "content of #{url}"}
    end
  end
end

# =============================================================================
# Exercise 2: Parallel Map with Progress
# =============================================================================
# Process items with progress reporting:
# - Process in parallel
# - Call progress_fn with {completed, total} after each item
# - Return all results

defmodule Exercise2 do
  def map_with_progress(items, process_fn, progress_fn) do
    # Hint: Use Task.async_stream and track completion
    :todo
  end
end

# =============================================================================
# Exercise 3: Agent-based Counter with History
# =============================================================================
# Counter that keeps history of all values

defmodule HistoryCounter do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> {0, []} end, name: __MODULE__)
  end

  def get do
    # Return current value
    :todo
  end

  def history do
    # Return list of past values (newest first)
    :todo
  end

  def increment do
    # Add current to history, then increment
    :todo
  end

  def rollback do
    # Restore previous value from history
    # Return :ok or {:error, :no_history}
    :todo
  end
end

# =============================================================================
# Exercise 4: Timeout with Fallback
# =============================================================================
# Execute with timeout and fallback:
# - Try primary function with timeout
# - If timeout, try fallback
# - If both fail, return error

defmodule Exercise4 do
  def execute(primary_fn, fallback_fn, timeout_ms) do
    # Return {:ok, result} or {:error, :all_failed}
    :todo
  end
end

# =============================================================================
# Exercise 5: Async Cache Loader
# =============================================================================
# Cache that loads missing values asynchronously
# - get(key) returns immediately with :loading or {:ok, value}
# - Missing keys trigger async load
# - Subsequent gets return :loading until ready

defmodule AsyncCache do
  use Agent

  def start_link(loader_fn) do
    # loader_fn: fn key -> value end
    Agent.start_link(fn -> %{loader: loader_fn, cache: %{}, loading: MapSet.new()} end, name: __MODULE__)
  end

  def get(key) do
    # Return {:ok, value} | :loading | :not_found
    # Trigger async load if not found and not loading
    :todo
  end

  def stop do
    Agent.stop(__MODULE__)
  end
end

# =============================================================================
# Tests
# =============================================================================

ExUnit.start(auto_run: false)

defmodule TaskAgentTest do
  use ExUnit.Case

  describe "Exercise 1 - Parallel fetcher" do
    test "fetches all URLs" do
      urls = ["http://a.com", "http://b.com", "http://c.com"]
      results = Exercise1.fetch_all(urls)

      assert length(results) == 3
      assert Enum.all?(results, fn {_url, result} -> match?({:ok, _}, result) end)
    end

    test "handles failures" do
      urls = ["http://good.com", "http://fail.com"]
      results = Exercise1.fetch_all(urls)

      assert {"http://good.com", {:ok, _}} = Enum.find(results, fn {url, _} -> url == "http://good.com" end)
      assert {"http://fail.com", {:error, _}} = Enum.find(results, fn {url, _} -> url == "http://fail.com" end)
    end
  end

  describe "Exercise 2 - Progress tracking" do
    test "reports progress" do
      parent = self()
      items = [1, 2, 3, 4, 5]

      Exercise2.map_with_progress(
        items,
        fn x -> x * 2 end,
        fn {done, total} -> send(parent, {:progress, done, total}) end
      )

      # Should receive 5 progress updates
      for i <- 1..5 do
        assert_receive {:progress, ^i, 5}
      end
    end

    test "returns results" do
      results = Exercise2.map_with_progress([1, 2, 3], &(&1 * 2), fn _ -> :ok end)
      assert Enum.sort(results) == [2, 4, 6]
    end
  end

  describe "Exercise 3 - History Counter" do
    setup do
      {:ok, _} = HistoryCounter.start_link([])
      on_exit(fn -> Agent.stop(HistoryCounter) end)
      :ok
    end

    test "increments and tracks history" do
      assert HistoryCounter.get() == 0
      HistoryCounter.increment()
      assert HistoryCounter.get() == 1
      assert HistoryCounter.history() == [0]
    end

    test "rollback restores previous" do
      HistoryCounter.increment()
      HistoryCounter.increment()
      assert HistoryCounter.get() == 2

      assert :ok = HistoryCounter.rollback()
      assert HistoryCounter.get() == 1
    end

    test "rollback fails when no history" do
      assert {:error, :no_history} = HistoryCounter.rollback()
    end
  end

  describe "Exercise 4 - Timeout with fallback" do
    test "returns primary result on success" do
      result = Exercise4.execute(
        fn -> 42 end,
        fn -> 0 end,
        1000
      )
      assert result == {:ok, 42}
    end

    test "falls back on timeout" do
      result = Exercise4.execute(
        fn -> Process.sleep(1000); 42 end,
        fn -> :fallback end,
        50
      )
      assert result == {:ok, :fallback}
    end

    test "returns error if both fail" do
      result = Exercise4.execute(
        fn -> Process.sleep(1000) end,
        fn -> Process.sleep(1000) end,
        50
      )
      assert result == {:error, :all_failed}
    end
  end

  describe "Exercise 5 - Async cache" do
    setup do
      loader = fn key ->
        Process.sleep(50)
        "value_for_#{key}"
      end
      {:ok, _} = AsyncCache.start_link(loader)
      on_exit(fn -> AsyncCache.stop() end)
      :ok
    end

    test "returns :loading for missing key" do
      assert AsyncCache.get("key1") == :loading
    end

    test "returns value after load completes" do
      AsyncCache.get("key2")
      Process.sleep(100)
      assert AsyncCache.get("key2") == {:ok, "value_for_key2"}
    end
  end
end

ExUnit.run()
