# Registry

**Usefulness: 8/10** - Local process registry. Essential for dynamic process naming.

Registry provides a decentralized, scalable key-value store for process registration.

## Basic Usage

### Setup

```elixir
# In your supervision tree
children = [
  {Registry, keys: :unique, name: MyApp.Registry}
]
```

### Registering Processes

```elixir
# Using {:via, Registry, ...} tuple
defmodule MyWorker do
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: via_tuple(id))
  end

  defp via_tuple(id) do
    {:via, Registry, {MyApp.Registry, id}}
  end

  def get(id) do
    GenServer.call(via_tuple(id), :get)
  end
end
```

## Unique vs Duplicate Keys

### Unique Keys

One process per key.

```elixir
{Registry, keys: :unique, name: MyApp.Registry}

# Register
Registry.register(MyApp.Registry, "user:123", %{role: :admin})

# Lookup - returns list of {pid, value}
Registry.lookup(MyApp.Registry, "user:123")
# [{#PID<0.123.0>, %{role: :admin}}]
```

### Duplicate Keys

Multiple processes per key. Great for pub/sub.

```elixir
{Registry, keys: :duplicate, name: MyApp.PubSub}

# Multiple processes can register with same key
Registry.register(MyApp.PubSub, "topic:news", [])
Registry.register(MyApp.PubSub, "topic:news", [])

# Lookup returns all
Registry.lookup(MyApp.PubSub, "topic:news")
# [{#PID<0.123.0>, []}, {#PID<0.124.0>, []}]

# Dispatch to all
Registry.dispatch(MyApp.PubSub, "topic:news", fn entries ->
  for {pid, _value} <- entries do
    send(pid, {:news, "Breaking news!"})
  end
end)
```

## Registry Options

```elixir
{Registry,
  keys: :unique,
  name: MyApp.Registry,
  partitions: System.schedulers_online(),  # For scalability
  meta: [stats: true]  # Store metadata
}
```

## Common Patterns

### Dynamic Worker Lookup

```elixir
defmodule MyApp.UserWorkerSupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_worker(user_id) do
    spec = {MyApp.UserWorker, user_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def get_worker(user_id) do
    case Registry.lookup(MyApp.Registry, {:user, user_id}) do
      [{pid, _}] -> {:ok, pid}
      [] -> :not_found
    end
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule MyApp.UserWorker do
  use GenServer

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id,
      name: {:via, Registry, {MyApp.Registry, {:user, user_id}}})
  end
end
```

### Pub/Sub with Registry

```elixir
defmodule MyApp.Events do
  def subscribe(topic) do
    Registry.register(MyApp.EventRegistry, topic, [])
  end

  def broadcast(topic, message) do
    Registry.dispatch(MyApp.EventRegistry, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:event, topic, message})
    end)
  end
end

# Usage
MyApp.Events.subscribe("user:created")

receive do
  {:event, "user:created", user} -> IO.inspect(user)
end
```

### Process Metadata

```elixir
# Register with metadata
Registry.register(MyApp.Registry, "worker:1", %{started_at: DateTime.utc_now()})

# Update metadata
Registry.update_value(MyApp.Registry, "worker:1", fn old ->
  Map.put(old, :last_ping, DateTime.utc_now())
end)

# Query by metadata
Registry.select(MyApp.Registry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])
```

## Match Specs

Select processes matching criteria.

```elixir
# Find all workers
Registry.select(MyApp.Registry, [
  {{{:worker, :"$1"}, :"$2", :"$3"}, [], [{{:"$1", :"$2"}}]}
])

# Count by pattern
Registry.count_match(MyApp.Registry, {:worker, :_}, :_)
```

---

## Exercises

### Exercise 1: Session Registry
```elixir
# Create a session registry that:
# - Tracks user sessions by session_id
# - Allows looking up all sessions for a user_id
# - Supports session expiration

defmodule SessionRegistry do
  # Your code here
end
```

### Exercise 2: Service Discovery
```elixir
# Implement local service discovery:
# - Services register with type and metadata
# - Clients can find services by type
# - Load balance across instances

defmodule ServiceDiscovery do
  def register(service_type, metadata) do
    # Your code here
  end

  def find_one(service_type) do
    # Return a random instance
  end

  def find_all(service_type) do
    # Return all instances
  end
end
```

---

## Registry vs ETS vs Agent

| Use Case | Best Choice |
|----------|-------------|
| Process naming | Registry |
| Fast read-heavy cache | ETS |
| Simple shared state | Agent |
| Pub/sub | Registry (duplicate keys) |
| Large datasets | ETS |
