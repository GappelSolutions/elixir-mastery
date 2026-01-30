# Application

**Usefulness: 9/10** - Your app's entry point and supervision tree root.

An Application is an OTP component that can be started/stopped as a unit. It's the container for your supervision tree.

## Basic Application

```elixir
defmodule MyApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MyApp.Repo,
      MyApp.Cache,
      {MyApp.Worker, name: MyApp.Worker},
      MyAppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

## mix.exs Configuration

```elixir
def application do
  [
    mod: {MyApp.Application, []},
    extra_applications: [:logger, :runtime_tools]
  ]
end
```

## Start Types

```elixir
@impl true
def start(type, args)

# type can be:
# :normal - Standard start
# {:takeover, node} - Taking over from another node
# {:failover, node} - Failing over from another node
```

## Stop Callback

```elixir
@impl true
def stop(_state) do
  # Cleanup code here
  :ok
end
```

## Application Environment

Configuration stored per-application.

```elixir
# config/config.exs
config :my_app,
  pool_size: 10,
  timeout: 5000

# Access at runtime
Application.get_env(:my_app, :pool_size)  # 10
Application.get_env(:my_app, :missing, "default")  # "default"

# All config for an app
Application.get_all_env(:my_app)

# Set at runtime (usually avoid)
Application.put_env(:my_app, :key, "value")

# Fetch (raises if missing)
Application.fetch_env!(:my_app, :pool_size)
```

## Runtime vs Compile-time Config

```elixir
# config/config.exs - Compile time
config :my_app, pool_size: 10

# config/runtime.exs - Runtime (Elixir 1.11+)
config :my_app,
  database_url: System.get_env("DATABASE_URL"),
  secret_key: System.get_env("SECRET_KEY")

# In code - always runtime
defmodule MyApp.Repo do
  def pool_size do
    Application.get_env(:my_app, :pool_size, 10)
  end
end
```

## Application Callbacks

```elixir
defmodule MyApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [...]
    Supervisor.start_link(children, name: MyApp.Supervisor)
  end

  @impl true
  def stop(_state) do
    # Called when application stops
    :ok
  end

  @impl true
  def prep_stop(state) do
    # Called before stop, return value passed to stop/1
    state
  end

  @impl true
  def config_change(changed, new, removed) do
    # Called after config reload
    :ok
  end
end
```

## Starting Applications

```elixir
# Start an application
Application.start(:my_app)

# Ensure started (starts dependencies too)
Application.ensure_all_started(:my_app)

# Stop
Application.stop(:my_app)

# Check if running
Application.started_applications()
```

## Accessing Application Info

```elixir
Application.spec(:my_app)
Application.spec(:my_app, :vsn)  # Version

# Get all loaded applications
Application.loaded_applications()
```

## Common Pattern: Start Args

```elixir
# mix.exs
def application do
  [
    mod: {MyApp.Application, [env: Mix.env()]}
  ]
end

# application.ex
def start(_type, args) do
  env = Keyword.get(args, :env, :prod)
  # Use env to configure
end
```

---

## Exercises

### Exercise 1: Conditional Children
```elixir
# Start different children based on config
# - In dev: start mock services
# - In prod: start real services

defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = base_children() ++ env_children()
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp base_children do
    # Your code here
  end

  defp env_children do
    # Your code here based on Application.get_env(:my_app, :env)
  end
end
```

### Exercise 2: Graceful Shutdown
```elixir
# Implement prep_stop and stop callbacks that:
# - Signal workers to finish current work
# - Wait for pending operations
# - Log shutdown progress
```

---

## Common Mistakes

### 1. Using Application.get_env at Compile Time

```elixir
# BAD - evaluated at compile time
defmodule MyModule do
  @pool_size Application.get_env(:my_app, :pool_size)
end

# GOOD - evaluated at runtime
defmodule MyModule do
  def pool_size do
    Application.get_env(:my_app, :pool_size)
  end
end
```

### 2. Hardcoding Child Order

```elixir
# Remember: children start in order, stop in reverse
children = [
  Database,      # Starts first, stops last
  Cache,         # Starts second, stops second-to-last
  WebServer      # Starts last, stops first
]
```
