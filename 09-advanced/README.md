# Advanced Topics

The deep end. Months 9-12 territory.

## Learning Order

1. [Distributed Elixir](01-distributed.md)
2. [ETS Tables](02-ets.md)
3. [NIFs & Ports](03-nifs-ports.md)
4. [Telemetry](04-telemetry.md)
5. [Umbrella Apps](05-umbrella.md)
6. [Hot Code Upgrades](06-hot-upgrades.md)

## Distributed Elixir

Connect BEAM nodes into a cluster.

```elixir
# Start named nodes
# Terminal 1
iex --sname node1@localhost

# Terminal 2
iex --sname node2@localhost

# Connect
Node.connect(:"node1@localhost")
Node.list()  # [:"node1@localhost"]

# Execute on remote node
Node.spawn(:"node1@localhost", fn -> IO.puts("Hello from node1!") end)

# GenServer calls work across nodes
GenServer.call({MyServer, :"node1@localhost"}, :request)
```

### Process Groups

```elixir
# Start :pg
:pg.start(:my_scope)

# Join a group
:pg.join(:my_scope, :workers, self())

# Get members
:pg.get_members(:my_scope, :workers)

# Broadcast to all
for pid <- :pg.get_members(:my_scope, :workers) do
  send(pid, :work)
end
```

### Global Registry

```elixir
:global.register_name(:unique_process, self())
:global.whereis_name(:unique_process)  # PID
```

## ETS (Erlang Term Storage)

In-memory key-value storage. Faster than GenServer for reads.

```elixir
# Create table
table = :ets.new(:my_cache, [:set, :public, :named_table])

# Insert
:ets.insert(:my_cache, {"key", "value"})
:ets.insert(:my_cache, [{"k1", "v1"}, {"k2", "v2"}])

# Lookup
:ets.lookup(:my_cache, "key")  # [{"key", "value"}]

# Delete
:ets.delete(:my_cache, "key")

# Match
:ets.match(:my_cache, {:"$1", "value"})  # [["key"]]

# Table types
:set        # Unique keys, latest value wins
:ordered_set # Keys sorted
:bag        # Duplicate keys, unique values
:duplicate_bag # Anything goes
```

### ETS with GenServer

```elixir
defmodule Cache do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get(key) do
    case :ets.lookup(:cache, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :not_found
    end
  end

  def put(key, value) do
    GenServer.call(__MODULE__, {:put, key, value})
  end

  @impl true
  def init(:ok) do
    table = :ets.new(:cache, [:set, :named_table, :public, read_concurrency: true])
    {:ok, table}
  end

  @impl true
  def handle_call({:put, key, value}, _from, table) do
    :ets.insert(table, {key, value})
    {:reply, :ok, table}
  end
end
```

## NIFs (Native Implemented Functions)

Call Rust/C from Elixir. For CPU-intensive work.

```elixir
# Using Rustler (Rust NIFs)
# mix.exs
{:rustler, "~> 0.30"}

# lib/my_nif.ex
defmodule MyNif do
  use Rustler, otp_app: :my_app, crate: "my_nif"

  def expensive_calculation(_arg), do: :erlang.nif_error(:nif_not_loaded)
end

# native/my_nif/src/lib.rs
#[rustler::nif]
fn expensive_calculation(input: i64) -> i64 {
    // Rust code here
}
```

**Warning**: NIFs can crash the BEAM. Use Ports for untrusted code.

## Ports

Communicate with external programs.

```elixir
port = Port.open({:spawn, "cat"}, [:binary])
send(port, {self(), {:command, "hello\n"}})

receive do
  {^port, {:data, data}} -> IO.puts("Got: #{data}")
end

Port.close(port)
```

## Telemetry

Metrics and instrumentation.

```elixir
# Emit event
:telemetry.execute(
  [:my_app, :request, :done],
  %{duration: 123},
  %{path: "/users"}
)

# Attach handler
:telemetry.attach(
  "my-handler",
  [:my_app, :request, :done],
  fn _event, measurements, metadata, _config ->
    Logger.info("Request to #{metadata.path} took #{measurements.duration}ms")
  end,
  nil
)
```

### Phoenix Telemetry

```elixir
# Already emits events for:
# [:phoenix, :endpoint, :start/:stop]
# [:phoenix, :router_dispatch, :start/:stop]
# [:phoenix, :live_view, :mount/:handle_event/:...]
# [:ecto, :repo, :query]
```

---

## Exercises

### Exercise 1: Distributed Counter
```elixir
# Create a counter that:
# - Works across multiple nodes
# - Survives node failures
# - Eventually consistent
# - Uses CRDT pattern (grow-only counter)
```

### Exercise 2: ETS Cache with TTL
```elixir
# Build a cache with:
# - ETS for storage
# - TTL per entry
# - Automatic cleanup
# - Stats (hit rate, size)
```

### Exercise 3: Rust NIF
```elixir
# Implement in Rust:
# - Image resizing
# - JSON parsing (compare performance)
# - Cryptographic hashing
```

### Exercise 4: Distributed Task Queue
```elixir
# Build a job queue that:
# - Distributes work across nodes
# - Handles worker failures
# - Provides exactly-once semantics
# - Persists jobs to survive restarts
```
