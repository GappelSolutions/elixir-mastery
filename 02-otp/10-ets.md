# ETS (Erlang Term Storage)

**Usefulness: 9/10** - Blazing fast in-memory storage. The secret weapon for performance.

ETS provides in-memory key-value storage with O(1) lookups. No message passing overhead.

## Creating Tables

```elixir
# Named table
table = :ets.new(:my_cache, [:set, :named_table, :public])

# Options
:ets.new(:cache, [
  :set,                    # Table type
  :named_table,            # Access by name
  :public,                 # Any process can access
  read_concurrency: true,  # Optimize for reads
  write_concurrency: true  # Optimize for writes
])
```

## Table Types

```elixir
:set           # Unique keys, one value per key
:ordered_set   # Keys sorted, unique
:bag           # Duplicate keys allowed, unique {key, value} pairs
:duplicate_bag # Any duplicates allowed
```

## Access Modes

```elixir
:public     # Any process can read/write
:protected  # Owner writes, any reads (default)
:private    # Only owner can access
```

## Basic Operations

```elixir
# Insert
:ets.insert(:cache, {"key", "value"})
:ets.insert(:cache, [{"a", 1}, {"b", 2}])

# Lookup
:ets.lookup(:cache, "key")  # [{"key", "value"}]

# Member check
:ets.member(:cache, "key")  # true

# Delete
:ets.delete(:cache, "key")
:ets.delete_all_objects(:cache)

# Count
:ets.info(:cache, :size)  # Number of entries
```

## Pattern Matching

```elixir
# Insert some data
:ets.insert(:users, [
  {"user:1", %{name: "Alice", role: :admin}},
  {"user:2", %{name: "Bob", role: :user}},
  {"user:3", %{name: "Carol", role: :admin}}
])

# Match by pattern
:ets.match(:users, {"user:$1", %{role: :admin}})
# [["1"], ["3"]]

# Match object (return full tuples)
:ets.match_object(:users, {:_, %{role: :admin}})

# Select with guards
:ets.select(:users, [
  {{"user:$1", %{name: "$2", role: :admin}}, [], [{{:"$1", :"$2"}}]}
])
# [{"1", "Alice"}, {"3", "Carol"}]
```

## Match Specs

Powerful query language for ETS.

```elixir
# Find users where name starts with "A"
match_spec = [
  {
    {:_, %{name: :"$1", role: :"$2"}},  # Pattern
    [{:==, {:hd, :"$1"}, ?A}],           # Guards
    [{{:"$1", :"$2"}}]                   # Return
  }
]
:ets.select(:users, match_spec)

# Use ets.fun2ms for readable match specs
import Ex2ms

fun = Ex2ms.fun do
  {key, %{name: name, role: role}} when role == :admin -> {key, name}
end

:ets.select(:users, fun)
```

## Atomic Operations

```elixir
# Update counter
:ets.update_counter(:stats, :hits, 1)
:ets.update_counter(:stats, :hits, {2, 1})  # Increment position 2 by 1

# Insert new (fails if exists)
:ets.insert_new(:cache, {"key", "value"})  # true/false

# Compare and swap (via lookup + insert)
# ETS doesn't have native CAS, but you can use take
old = :ets.take(:cache, "key")  # Returns and deletes
```

## ETS with GenServer

Common pattern: GenServer owns table, provides API.

```elixir
defmodule Cache do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Public API (direct ETS access for reads)
  def get(key) do
    case :ets.lookup(:cache_table, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :not_found
    end
  end

  # Writes go through GenServer
  def put(key, value) do
    GenServer.call(__MODULE__, {:put, key, value})
  end

  # Callbacks
  @impl true
  def init(:ok) do
    table = :ets.new(:cache_table, [
      :set,
      :named_table,
      :public,
      read_concurrency: true
    ])
    {:ok, table}
  end

  @impl true
  def handle_call({:put, key, value}, _from, table) do
    :ets.insert(table, {key, value})
    {:reply, :ok, table}
  end
end
```

## Persistence: DETS

Disk-based ETS.

```elixir
# Open/create file
{:ok, table} = :dets.open_file(:my_dets, [type: :set])

# Same API as ETS
:dets.insert(table, {"key", "value"})
:dets.lookup(table, "key")

# Sync to disk
:dets.sync(table)

# Close
:dets.close(table)
```

**Warning**: DETS is slower and limited to 2GB. For serious persistence, use a database.

---

## Exercises

### Exercise 1: LRU Cache
```elixir
# Implement LRU cache with:
# - Max size
# - Access updates timestamp
# - Eviction of oldest entries

defmodule LRUCache do
  def start_link(max_size) do
    # Your code here
  end

  def get(key) do
    # Update access time, return value
  end

  def put(key, value) do
    # Insert, evict if needed
  end
end
```

### Exercise 2: Rate Limiter
```elixir
# Token bucket rate limiter using ETS

defmodule RateLimiter do
  def allow?(key, max_requests, window_ms) do
    # Your code here
  end
end
```

### Exercise 3: Session Store
```elixir
# Session storage with:
# - TTL per session
# - Automatic cleanup
# - Statistics

defmodule SessionStore do
  # Your code here
end
```

---

## Performance Tips

1. **Use `read_concurrency: true`** for read-heavy workloads
2. **Use `write_concurrency: true`** for write-heavy workloads
3. **Use `:ordered_set`** only when you need sorted iteration
4. **Avoid large match operations** - they scan the table
5. **Use lookup, not match** for known keys

## ETS vs Alternatives

| Use Case | Best Choice |
|----------|-------------|
| Fast lookups | ETS |
| Simple state | Agent |
| Persistence | Database |
| Distributed | Mnesia, external DB |
| Message passing | GenServer |
