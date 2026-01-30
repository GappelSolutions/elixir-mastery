# Agent

**Usefulness: 7/10** - Simple state wrapper. GenServer-lite.

Agent is a simple abstraction around state. Use when you just need state without complex message handling.

## Basic Usage

```elixir
# Start with initial state
{:ok, agent} = Agent.start_link(fn -> 0 end)

# Get state
Agent.get(agent, fn state -> state end)  # 0

# Update state
Agent.update(agent, fn state -> state + 1 end)

# Get and update atomically
Agent.get_and_update(agent, fn state ->
  {state, state + 1}
end)  # Returns old value, updates to new

# Cast (async update)
Agent.cast(agent, fn state -> state + 1 end)

# Stop
Agent.stop(agent)
```

## Named Agent

```elixir
Agent.start_link(fn -> %{} end, name: MyAgent)

Agent.get(MyAgent, & &1)
Agent.update(MyAgent, &Map.put(&1, :key, "value"))
```

## Module-Based Agent

```elixir
defmodule Counter do
  use Agent

  def start_link(initial) do
    Agent.start_link(fn -> initial end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, & &1)
  end

  def increment do
    Agent.update(__MODULE__, &(&1 + 1))
  end

  def increment_and_get do
    Agent.get_and_update(__MODULE__, fn n -> {n + 1, n + 1} end)
  end
end

Counter.start_link(0)
Counter.increment()
Counter.get()  # 1
```

## Supervised Agent

```elixir
# In supervision tree
children = [
  {Agent, fn -> %{} end, name: MyApp.Cache}
]

# Or with module
children = [
  {MyApp.Counter, 0}
]
```

## Common Patterns

### Simple Cache

```elixir
defmodule SimpleCache do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def put(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def get_or_put(key, fun) do
    Agent.get_and_update(__MODULE__, fn state ->
      case Map.get(state, key) do
        nil ->
          value = fun.()
          {value, Map.put(state, key, value)}
        value ->
          {value, state}
      end
    end)
  end
end
```

### Accumulator

```elixir
defmodule Accumulator do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(item) do
    Agent.update(__MODULE__, &[item | &1])
  end

  def flush do
    Agent.get_and_update(__MODULE__, fn items ->
      {Enum.reverse(items), []}
    end)
  end
end
```

## Agent Options

```elixir
Agent.start_link(fn -> state end,
  name: MyAgent,       # Process name
  timeout: 5000,       # Init timeout
  spawn_opt: [],       # Process spawn options
  hibernate_after: 15_000  # Hibernate after idle
)

# Operation timeouts
Agent.get(agent, & &1, 10_000)
Agent.update(agent, & &1, 10_000)
```

---

## Exercises

### Exercise 1: Stateful Counter with History
```elixir
# Counter that keeps history of values

defmodule HistoryCounter do
  use Agent

  def start_link(_) do
    # State: {current, [history]}
  end

  def get, do: # current value
  def history, do: # list of past values
  def increment, do: # add current to history, increment
  def rollback, do: # restore previous value
end
```

### Exercise 2: Rate Counter
```elixir
# Track events per time window

defmodule RateCounter do
  use Agent

  def start_link(window_ms) do
    # Your code here
  end

  def record do
    # Record an event
  end

  def rate do
    # Events per window
  end
end
```

---

## Agent vs GenServer

| Agent | GenServer |
|-------|-----------|
| State only | State + behavior |
| Simpler API | Full control |
| No handle_info | Handle any message |
| No custom callbacks | Custom callbacks |

### When to Graduate to GenServer

- Need `handle_info` for timers/monitors
- Complex initialization
- Need to receive arbitrary messages
- Cleanup in `terminate`
- Performance (Agent has overhead)

```elixir
# Agent - simple state
defmodule Cache do
  use Agent
  def get(key), do: Agent.get(__MODULE__, &Map.get(&1, key))
end

# GenServer - when you need more
defmodule Cache do
  use GenServer

  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    # Periodic cleanup - can't do this with Agent
    {:noreply, cleanup_expired(state)}
  end
end
```

---

## Gotchas

### Long-Running Functions

```elixir
# BAD - blocks the agent
Agent.update(agent, fn state ->
  expensive_operation()  # Blocks all other operations
  new_state
end)

# GOOD - compute outside, then update
result = expensive_operation()
Agent.update(agent, fn state ->
  apply_result(state, result)
end)
```

### Process Bottleneck

All operations serialize through one process. For high-throughput, consider:
- ETS for reads
- Partitioned agents
- GenServer with ETS backend
