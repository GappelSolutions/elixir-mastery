# Advanced Exercises: ETS & Distributed Elixir
# Run: elixir exercises/09-advanced/01-ets-distributed.ex

# =============================================================================
# Exercise 1: LRU Cache with ETS
# =============================================================================
# Implement an LRU (Least Recently Used) cache:
# - Fixed max size
# - Evict oldest entries when full
# - O(1) get and put (hint: use two ETS tables)

defmodule LRUCache do
  use GenServer

  def start_link(opts) do
    max_size = Keyword.fetch!(opts, :max_size)
    GenServer.start_link(__MODULE__, max_size, name: __MODULE__)
  end

  def get(key) do
    :todo
  end

  def put(key, value) do
    :todo
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  @impl true
  def init(max_size) do
    # Create ETS tables:
    # - :lru_data for key -> {value, timestamp}
    # - :lru_order for timestamp -> key (ordered_set)
    :todo
  end

  # Implement handle_call for :get and :put
  # On get: update timestamp
  # On put: evict if full, insert new
end

# =============================================================================
# Exercise 2: Rate Counter with ETS
# =============================================================================
# Track events per time window using ETS:
# - record(key) - record an event
# - count(key) - events in current window
# - Automatic cleanup of old windows

defmodule RateCounter do
  use GenServer

  def start_link(opts) do
    window_ms = Keyword.get(opts, :window_ms, 60_000)
    GenServer.start_link(__MODULE__, window_ms, name: __MODULE__)
  end

  def record(key) do
    :todo
  end

  def count(key) do
    :todo
  end

  @impl true
  def init(window_ms) do
    table = :ets.new(:rate_counter, [:set, :public, :named_table])
    # Schedule cleanup
    {:ok, %{table: table, window_ms: window_ms}}
  end

  # Use :ets.update_counter for atomic increments
  # Store as {key, count, window_start}
end

# =============================================================================
# Exercise 3: Distributed Counter (CRDT-style)
# =============================================================================
# Implement a grow-only counter that works across nodes:
# - Each node tracks its own count
# - get() returns sum across all known nodes
# - Merges with other nodes on sync

defmodule GCounter do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def increment do
    GenServer.cast(__MODULE__, :increment)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def merge(remote_state) do
    GenServer.cast(__MODULE__, {:merge, remote_state})
  end

  def state do
    GenServer.call(__MODULE__, :state)
  end

  @impl true
  def init(_opts) do
    # State: %{node() => count}
    {:ok, %{node() => 0}}
  end

  @impl true
  def handle_cast(:increment, state) do
    {:noreply, Map.update(state, node(), 1, &(&1 + 1))}
  end

  @impl true
  def handle_cast({:merge, remote_state}, state) do
    # Merge by taking max for each node
    merged = Map.merge(state, remote_state, fn _k, v1, v2 -> max(v1, v2) end)
    {:noreply, merged}
  end

  @impl true
  def handle_call(:get, _from, state) do
    total = state |> Map.values() |> Enum.sum()
    {:reply, total, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
end

# =============================================================================
# Exercise 4: Process Registry with ETS
# =============================================================================
# Build a simple process registry:
# - register(name, pid)
# - lookup(name) -> pid | nil
# - unregister(name)
# - Auto-cleanup when process dies (monitor)

defmodule SimpleRegistry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def register(name, pid \\ self()) do
    :todo
  end

  def lookup(name) do
    :todo
  end

  def unregister(name) do
    :todo
  end

  @impl true
  def init(_) do
    table = :ets.new(:registry, [:set, :named_table, :public])
    {:ok, %{table: table, monitors: %{}}}
  end

  # Implement handle_call/handle_info
  # Monitor registered processes
  # Clean up on :DOWN message
end

# =============================================================================
# Tests
# =============================================================================

ExUnit.start(auto_run: false)

defmodule AdvancedTest do
  use ExUnit.Case

  describe "Exercise 1 - LRU Cache" do
    setup do
      {:ok, _} = LRUCache.start_link(max_size: 3)
      on_exit(fn -> LRUCache.stop() end)
      :ok
    end

    test "stores and retrieves" do
      LRUCache.put("a", 1)
      assert LRUCache.get("a") == {:ok, 1}
    end

    test "evicts oldest when full" do
      LRUCache.put("a", 1)
      LRUCache.put("b", 2)
      LRUCache.put("c", 3)
      LRUCache.put("d", 4)  # Should evict "a"

      assert LRUCache.get("a") == :not_found
      assert LRUCache.get("b") == {:ok, 2}
    end

    test "get updates recency" do
      LRUCache.put("a", 1)
      LRUCache.put("b", 2)
      LRUCache.put("c", 3)
      LRUCache.get("a")  # "a" is now most recent
      LRUCache.put("d", 4)  # Should evict "b" (oldest)

      assert LRUCache.get("a") == {:ok, 1}
      assert LRUCache.get("b") == :not_found
    end
  end

  describe "Exercise 3 - GCounter" do
    setup do
      {:ok, _} = GCounter.start_link([])
      on_exit(fn -> GenServer.stop(GCounter) end)
      :ok
    end

    test "increments locally" do
      GCounter.increment()
      GCounter.increment()
      assert GCounter.get() == 2
    end

    test "merges with remote state" do
      GCounter.increment()
      remote_state = %{:"node2@host" => 5}
      GCounter.merge(remote_state)

      assert GCounter.get() == 6
    end

    test "merge takes max" do
      GCounter.increment()
      GCounter.increment()
      # Remote node has lower count for our node
      remote_state = %{node() => 1, :"other@host" => 3}
      GCounter.merge(remote_state)

      # Should keep our higher count (2), add remote (3)
      assert GCounter.get() == 5
    end
  end

  describe "Exercise 4 - Registry" do
    setup do
      {:ok, _} = SimpleRegistry.start_link([])
      on_exit(fn -> GenServer.stop(SimpleRegistry) end)
      :ok
    end

    test "registers and looks up" do
      SimpleRegistry.register(:test, self())
      assert SimpleRegistry.lookup(:test) == self()
    end

    test "unregisters" do
      SimpleRegistry.register(:test, self())
      SimpleRegistry.unregister(:test)
      assert SimpleRegistry.lookup(:test) == nil
    end

    test "cleans up when process dies" do
      pid = spawn(fn -> receive do: (:stop -> :ok) end)
      SimpleRegistry.register(:worker, pid)
      assert SimpleRegistry.lookup(:worker) == pid

      send(pid, :stop)
      Process.sleep(50)

      assert SimpleRegistry.lookup(:worker) == nil
    end
  end
end

ExUnit.run()
