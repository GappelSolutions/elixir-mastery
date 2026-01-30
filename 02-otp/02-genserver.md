# GenServer

**Usefulness: 10/10** - The workhorse of Elixir applications.

GenServer (Generic Server) abstracts the common patterns of stateful processes: initialization, synchronous calls, async messages, termination.

## Basic Structure

```elixir
defmodule Counter do
  use GenServer

  # Client API

  def start_link(initial \\ 0) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def increment do
    GenServer.cast(__MODULE__, :increment)
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  # Server Callbacks

  @impl true
  def init(initial) do
    {:ok, initial}
  end

  @impl true
  def handle_cast(:increment, count) do
    {:noreply, count + 1}
  end

  @impl true
  def handle_call(:get, _from, count) do
    {:reply, count, count}
  end
end
```

## Client vs Server

```
Client Process              GenServer Process
      │                            │
      ├──── call(:get) ───────────>│
      │                            │ handle_call
      │<─── {:reply, value} ───────│
      │                            │
      ├──── cast(:incr) ──────────>│
      │ (doesn't wait)             │ handle_cast
      │                            │
```

## Callbacks

### init/1

Called when server starts.

```elixir
@impl true
def init(arg) do
  # Return values:
  {:ok, state}                    # Normal start
  {:ok, state, timeout}           # Start with timeout
  {:ok, state, :hibernate}        # Start and hibernate
  {:ok, state, {:continue, term}} # Start then handle_continue
  :ignore                         # Don't start, no error
  {:stop, reason}                 # Don't start, with error
end

# Example with setup
def init(opts) do
  table = :ets.new(:cache, [:set, :protected])
  {:ok, %{table: table, opts: opts}}
end
```

### handle_call/3

Synchronous request. Caller blocks until response.

```elixir
@impl true
def handle_call(request, from, state)

# from = {caller_pid, reference}

# Return values:
{:reply, response, new_state}
{:reply, response, new_state, timeout}
{:reply, response, new_state, :hibernate}
{:reply, response, new_state, {:continue, term}}
{:noreply, new_state}              # Reply manually later
{:stop, reason, response, new_state}  # Stop after replying
{:stop, reason, new_state}         # Stop without reply
```

```elixir
@impl true
def handle_call(:get, _from, state) do
  {:reply, state, state}
end

def handle_call({:set, value}, _from, _state) do
  {:reply, :ok, value}
end

def handle_call(:pop, _from, [head | tail]) do
  {:reply, head, tail}
end
```

### handle_cast/2

Asynchronous message. Fire and forget.

```elixir
@impl true
def handle_cast(request, state)

# Return values:
{:noreply, new_state}
{:noreply, new_state, timeout}
{:noreply, new_state, :hibernate}
{:noreply, new_state, {:continue, term}}
{:stop, reason, new_state}
```

```elixir
@impl true
def handle_cast(:increment, count) do
  {:noreply, count + 1}
end

def handle_cast({:push, item}, stack) do
  {:noreply, [item | stack]}
end
```

### handle_info/2

Handle messages not from call/cast (timers, monitors, custom sends).

```elixir
@impl true
def handle_info(msg, state)

# Example: timer
def init(_) do
  schedule_work()
  {:ok, %{}}
end

def handle_info(:work, state) do
  do_work()
  schedule_work()
  {:noreply, state}
end

defp schedule_work do
  Process.send_after(self(), :work, 60_000)  # Every minute
end

# Example: process monitoring
def init(_) do
  ref = Process.monitor(some_pid)
  {:ok, %{ref: ref}}
end

def handle_info({:DOWN, ref, :process, _pid, reason}, %{ref: ref} = state) do
  # Monitored process died
  {:noreply, %{state | status: :disconnected}}
end
```

### handle_continue/2

Deferred initialization or post-call processing.

```elixir
def init(_) do
  {:ok, %{}, {:continue, :load_data}}
end

@impl true
def handle_continue(:load_data, state) do
  data = expensive_load()
  {:noreply, %{state | data: data}}
end
```

### terminate/2

Called on graceful shutdown.

```elixir
@impl true
def terminate(reason, state) do
  # Cleanup resources
  :ok
end
```

**Note**: Not guaranteed to be called on crashes. Don't rely on it for critical cleanup.

---

## Naming

```elixir
# Local name (atom)
GenServer.start_link(__MODULE__, arg, name: :my_server)
GenServer.call(:my_server, :request)

# Module name (common pattern)
GenServer.start_link(__MODULE__, arg, name: __MODULE__)
GenServer.call(__MODULE__, :request)

# Via Registry
GenServer.start_link(__MODULE__, arg,
  name: {:via, Registry, {MyRegistry, "user:123"}})

# Global (cluster-wide)
GenServer.start_link(__MODULE__, arg,
  name: {:global, :cluster_singleton})
```

---

## Complete Example: Key-Value Store

```elixir
defmodule KVStore do
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  def get(server \\ __MODULE__, key) do
    GenServer.call(server, {:get, key})
  end

  def put(server \\ __MODULE__, key, value) do
    GenServer.call(server, {:put, key, value})
  end

  def delete(server \\ __MODULE__, key) do
    GenServer.cast(server, {:delete, key})
  end

  def keys(server \\ __MODULE__) do
    GenServer.call(server, :keys)
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  def handle_call({:put, key, value}, _from, state) do
    {:reply, :ok, Map.put(state, key, value)}
  end

  def handle_call(:keys, _from, state) do
    {:reply, Map.keys(state), state}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    {:noreply, Map.delete(state, key)}
  end
end
```

---

## Timeouts

### Call Timeout

```elixir
# Default: 5000ms
GenServer.call(server, request)

# Custom timeout
GenServer.call(server, request, 30_000)

# Infinite (careful!)
GenServer.call(server, request, :infinity)
```

### Server Timeout

```elixir
def handle_call(:request, _from, state) do
  {:reply, :ok, state, 10_000}  # Timeout after 10s idle
end

def handle_info(:timeout, state) do
  # No messages received for 10 seconds
  {:noreply, state}
end
```

---

## Exercises

### Exercise 1: Stack
```elixir
# Implement a stack GenServer with:
# - push(item)
# - pop() -> item
# - peek() -> item
# - size() -> integer

defmodule Stack do
  use GenServer
  # Your code here
end
```

### Exercise 2: Rate Limiter
```elixir
# Implement a rate limiter:
# - allow?(key) -> true if under limit, false otherwise
# - Configure: max requests per time window
# - Hint: use handle_info for cleanup

defmodule RateLimiter do
  use GenServer

  def start_link(opts) do
    # opts: max_requests, window_ms
  end

  def allow?(server, key) do
    # Your code here
  end
end
```

### Exercise 3: Pub/Sub
```elixir
# Simple publish-subscribe:
# - subscribe(topic) - current process subscribes
# - unsubscribe(topic)
# - publish(topic, message) - sends to all subscribers

defmodule PubSub do
  use GenServer
  # Your code here
end
```

### Exercise 4: Connection Pool
```elixir
# Manage a pool of connections:
# - checkout() -> {:ok, conn} | {:error, :empty}
# - checkin(conn)
# - Track checked-out connections by caller PID
# - Return connection if caller dies

defmodule Pool do
  use GenServer
  # Your code here
end
```

### Exercise 5: Cache with TTL
```elixir
# Key-value cache with expiration:
# - put(key, value, ttl_ms)
# - get(key) -> {:ok, value} | :not_found
# - Automatic cleanup of expired entries

defmodule TTLCache do
  use GenServer
  # Your code here
end
```

---

## Anti-Patterns

### Long-Running Calls

```elixir
# BAD - blocks caller for 10 seconds
def handle_call(:slow_query, _from, state) do
  result = slow_database_query()  # 10 seconds
  {:reply, result, state}
end

# GOOD - async processing
def handle_call(:slow_query, from, state) do
  Task.start(fn ->
    result = slow_database_query()
    GenServer.reply(from, result)
  end)
  {:noreply, state}
end
```

### Synchronous Everything

```elixir
# BAD - caller waits unnecessarily
def increment(server) do
  GenServer.call(server, :increment)
end

# GOOD - fire and forget when result isn't needed
def increment(server) do
  GenServer.cast(server, :increment)
end
```

### State Bottleneck

```elixir
# BAD - all requests serialize through one process
GenServer.call(SingletonServer, {:process_user, user_id})

# GOOD - partition by user_id
def process_user(user_id, data) do
  server = get_or_start_worker(user_id)
  GenServer.call(server, {:process, data})
end
```
