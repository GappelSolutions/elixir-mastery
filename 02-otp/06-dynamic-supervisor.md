# DynamicSupervisor

**Usefulness: 9/10** - Start children at runtime. Essential for dynamic workloads.

Unlike regular Supervisors where children are defined at compile time, DynamicSupervisor starts children dynamically at runtime.

## Basic Setup

```elixir
defmodule MyApp.WorkerSupervisor do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_worker(args) do
    spec = {MyApp.Worker, args}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
```

## Starting Children

```elixir
# With child spec
DynamicSupervisor.start_child(MySupervisor, {Worker, arg})

# With full spec
DynamicSupervisor.start_child(MySupervisor, %{
  id: Worker,
  start: {Worker, :start_link, [arg]},
  restart: :temporary
})

# With anonymous function (for one-off tasks)
DynamicSupervisor.start_child(MySupervisor, %{
  id: :task,
  start: {Task, :start_link, [fn -> do_work() end]},
  restart: :temporary
})
```

## Stopping Children

```elixir
# Terminate a specific child
DynamicSupervisor.terminate_child(MySupervisor, pid)

# Count children
DynamicSupervisor.count_children(MySupervisor)
# %{active: 5, specs: 5, supervisors: 0, workers: 5}

# List children
DynamicSupervisor.which_children(MySupervisor)
# [{:undefined, #PID<0.123.0>, :worker, [Worker]}, ...]
```

## Common Pattern: Per-Entity Workers

```elixir
defmodule MyApp.UserSession do
  use GenServer

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id,
      name: {:via, Registry, {MyApp.Registry, {:session, user_id}}})
  end

  # ...
end

defmodule MyApp.SessionSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_session(user_id) do
    spec = {MyApp.UserSession, user_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_session(user_id) do
    case Registry.lookup(MyApp.Registry, {:session, user_id}) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      [] -> :not_found
    end
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
```

## Max Children

Limit the number of children.

```elixir
def init(_) do
  DynamicSupervisor.init(
    strategy: :one_for_one,
    max_children: 100
  )
end

# start_child returns {:error, :max_children} when limit reached
```

## Extra Arguments

Pass additional arguments to all children.

```elixir
def init(opts) do
  DynamicSupervisor.init(
    strategy: :one_for_one,
    extra_arguments: [opts[:config]]
  )
end

# Worker receives: start_link(config, user_id)
def start_worker(user_id) do
  DynamicSupervisor.start_child(__MODULE__, {Worker, user_id})
end
```

## Restart Strategies for Dynamic Children

```elixir
# :temporary - never restart (default for Task.Supervisor)
# :transient - restart only on abnormal exit
# :permanent - always restart

spec = %{
  id: Worker,
  start: {Worker, :start_link, [args]},
  restart: :temporary  # Don't restart when done
}
```

---

## Task.Supervisor

A specialized DynamicSupervisor for tasks.

```elixir
# In supervision tree
{Task.Supervisor, name: MyApp.TaskSupervisor}

# Start async task
Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
  do_expensive_work()
end)

# Start task without linking
Task.Supervisor.start_child(MyApp.TaskSupervisor, fn ->
  do_background_work()
end)

# Parallel map with supervision
Task.Supervisor.async_stream(MyApp.TaskSupervisor, items, fn item ->
  process(item)
end)
|> Enum.to_list()
```

---

## Exercises

### Exercise 1: Connection Pool
```elixir
# Implement a connection pool:
# - Max N connections
# - Checkout/checkin
# - Auto-terminate idle connections
# - Queue requests when pool exhausted

defmodule ConnectionPool do
  use DynamicSupervisor
  # Your code here
end
```

### Exercise 2: Rate-Limited Worker Spawner
```elixir
# Spawn workers with rate limiting:
# - Max N workers per second
# - Queue excess requests
# - Configurable limits

defmodule RateLimitedSupervisor do
  # Your code here
end
```

---

## DynamicSupervisor vs Supervisor

| Feature | Supervisor | DynamicSupervisor |
|---------|-----------|-------------------|
| Children defined | At compile time | At runtime |
| Strategy | one_for_one, rest_for_one, one_for_all | one_for_one only |
| Use case | Static processes | Dynamic workloads |
| Child count | Fixed | Variable |
