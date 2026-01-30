# Supervisor

**Usefulness: 10/10** - The core of fault tolerance.

Supervisors monitor child processes and restart them when they crash.

## Basic Supervisor

```elixir
defmodule MyApp.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      {MyApp.Cache, []},
      {MyApp.Worker, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

## Child Specifications

Every supervised process needs a child spec.

```elixir
# Full spec
%{
  id: MyWorker,           # Unique identifier
  start: {MyWorker, :start_link, [[]]},  # {Module, function, args}
  restart: :permanent,    # Restart strategy
  shutdown: 5000,         # Shutdown timeout
  type: :worker           # :worker or :supervisor
}

# Using `use GenServer` auto-generates a spec
# Just pass the module
children = [
  MyApp.Cache,                    # Uses default spec
  {MyApp.Worker, [name: :w1]},   # With args
]
```

### Restart Values

```elixir
:permanent   # Always restart (default)
:temporary   # Never restart
:transient   # Restart only if abnormal exit
```

### Shutdown Values

```elixir
5000          # Wait 5 seconds, then kill
:infinity     # Wait forever (for supervisors)
:brutal_kill  # Kill immediately
```

## Restart Strategies

### :one_for_one

Only restart the crashed child.

```
Before:  [A] [B] [C]
C dies:  [A] [B] [C']   <- Only C restarted
```

```elixir
Supervisor.init(children, strategy: :one_for_one)
```

**Use when**: Children are independent.

### :one_for_all

Restart all children if any dies.

```
Before:  [A] [B] [C]
C dies:  [A'] [B'] [C']  <- All restarted
```

```elixir
Supervisor.init(children, strategy: :one_for_all)
```

**Use when**: Children are interdependent.

### :rest_for_one

Restart the crashed child and all started after it.

```
Before:  [A] [B] [C] [D]
B dies:  [A] [B'] [C'] [D']  <- B, C, D restarted
```

```elixir
Supervisor.init(children, strategy: :rest_for_one)
```

**Use when**: Later children depend on earlier ones.

## Restart Intensity

How many restarts allowed before supervisor gives up.

```elixir
Supervisor.init(children,
  strategy: :one_for_one,
  max_restarts: 3,      # Max restarts
  max_seconds: 5        # In this time window
)
```

Default: 3 restarts in 5 seconds. If exceeded, supervisor terminates.

## Supervision Trees

Supervisors can supervise other supervisors.

```elixir
defmodule MyApp.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children = [
      MyApp.Repo,                      # Database connection
      {MyApp.Cache.Supervisor, []},    # Cache subsystem
      {MyApp.Worker.Supervisor, []},   # Worker subsystem
      MyApp.Web.Endpoint               # Web server
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

## Module-based vs Inline

### Module-based (Preferred)

```elixir
defmodule MyApp.WorkerSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children = [...]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

### Inline (Quick & Simple)

```elixir
children = [
  {MyApp.Worker, []}
]

Supervisor.start_link(children, strategy: :one_for_one)
```

## Child Operations

```elixir
# Start a child
Supervisor.start_child(MySupervisor, child_spec)

# Stop a child
Supervisor.terminate_child(MySupervisor, child_id)

# Delete child spec (must be stopped first)
Supervisor.delete_child(MySupervisor, child_id)

# Restart a child
Supervisor.restart_child(MySupervisor, child_id)

# List children
Supervisor.which_children(MySupervisor)

# Count children
Supervisor.count_children(MySupervisor)
```

---

## Complete Example

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Start in order, top to bottom
      MyApp.Repo,
      {MyApp.Cache, name: :primary_cache},
      {Registry, keys: :unique, name: MyApp.Registry},
      {DynamicSupervisor, name: MyApp.TaskSupervisor, strategy: :one_for_one},
      MyAppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

---

## Exercises

### Exercise 1: Cascading Supervisor
```elixir
# Create a supervision tree:
# RootSupervisor
#   ├── Logger (GenServer)
#   ├── ConfigSupervisor (:rest_for_one)
#   │     ├── ConfigLoader
#   │     └── ConfigWatcher
#   └── WorkerSupervisor (:one_for_one)
#         ├── Worker1
#         ├── Worker2
#         └── Worker3

# Make workers crash randomly and observe restarts
```

### Exercise 2: Circuit Breaker
```elixir
# Implement a supervised circuit breaker:
# - After N failures, stop calling the service
# - Periodically try to recover
# - Use supervisor restart intensity as part of the pattern

defmodule CircuitBreaker do
  # Your code here
end
```

### Exercise 3: Supervised Task Pool
```elixir
# Create a pool of workers with:
# - Fixed number of supervised workers
# - Work queue (GenServer)
# - Workers pull from queue
# - If worker crashes, work is re-queued

defmodule TaskPool do
  # Your code here
end
```

---

## Debugging

```elixir
# In iex
:observer.start()

# Process tree
:sys.get_state(pid)
:sys.trace(pid, true)  # Log all messages

# Supervisor status
Supervisor.count_children(MySupervisor)
# %{active: 3, specs: 3, supervisors: 0, workers: 3}
```

## Best Practices

1. **Fail fast** - Let processes crash instead of defensive code
2. **Keep supervisors simple** - No business logic in supervisors
3. **Small failure domains** - Don't restart the world on every error
4. **Start order matters** - Dependencies first
5. **Test crash recovery** - Actually kill processes in tests
