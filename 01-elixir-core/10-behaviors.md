# Behaviors

**Usefulness: 8/10** - Compile-time contracts for modules.

Behaviors define a set of callbacks that a module must implement. Like interfaces for modules.

## Defining a Behavior

```elixir
defmodule Parser do
  @doc "Parse input string into structured data"
  @callback parse(String.t()) :: {:ok, term()} | {:error, String.t()}

  @doc "Supported file extensions"
  @callback extensions() :: [String.t()]

  @optional_callbacks extensions: 0
end
```

## Implementing a Behavior

```elixir
defmodule JSONParser do
  @behaviour Parser

  @impl Parser
  def parse(string) do
    Jason.decode(string)
  end

  @impl Parser
  def extensions do
    [".json"]
  end
end

defmodule YAMLParser do
  @behaviour Parser

  @impl Parser
  def parse(string) do
    YamlElixir.read_from_string(string)
  end

  # extensions/0 is optional, so we can skip it
end
```

## The `@impl` Attribute

Marks a function as implementing a callback. Provides compile-time verification.

```elixir
defmodule MyServer do
  @behaviour GenServer

  @impl GenServer
  def init(arg) do
    {:ok, arg}
  end

  @impl GenServer
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  # Compile warning if you forget @impl
  # Compile error if function doesn't match callback
end
```

## Common Built-in Behaviors

### GenServer

```elixir
@callback init(args :: term()) ::
  {:ok, state} |
  {:ok, state, timeout() | :hibernate | {:continue, term()}} |
  :ignore |
  {:stop, reason :: term()}

@callback handle_call(request :: term(), from(), state :: term()) ::
  {:reply, reply, new_state} |
  {:noreply, new_state} |
  {:stop, reason, reply, new_state} |
  {:stop, reason, new_state}

@callback handle_cast(request :: term(), state :: term()) ::
  {:noreply, new_state} |
  {:stop, reason :: term(), new_state}

@callback handle_info(msg :: term(), state :: term()) ::
  {:noreply, new_state} |
  {:stop, reason :: term(), new_state}

@callback terminate(reason, state :: term()) :: term()
```

### Supervisor

```elixir
@callback init(args :: term()) ::
  {:ok, {sup_flags(), [child_spec()]}} |
  :ignore
```

### Application

```elixir
@callback start(start_type(), start_args :: term()) ::
  {:ok, pid()} |
  {:ok, pid(), state()} |
  {:error, reason :: term()}

@callback stop(state()) :: term()
```

### Plug

```elixir
@callback init(opts :: term()) :: opts :: term()
@callback call(conn :: Plug.Conn.t(), opts :: term()) :: Plug.Conn.t()
```

## Dynamic Dispatch

Use behaviors for dependency injection.

```elixir
# Define behavior
defmodule MyApp.Mailer do
  @callback send(to :: String.t(), subject :: String.t(), body :: String.t()) ::
    :ok | {:error, term()}
end

# Production implementation
defmodule MyApp.Mailer.SMTP do
  @behaviour MyApp.Mailer

  @impl true
  def send(to, subject, body) do
    # Actually send email
  end
end

# Test implementation
defmodule MyApp.Mailer.Mock do
  @behaviour MyApp.Mailer

  @impl true
  def send(_to, _subject, _body) do
    :ok
  end
end

# Config
# config/prod.exs
config :my_app, mailer: MyApp.Mailer.SMTP

# config/test.exs
config :my_app, mailer: MyApp.Mailer.Mock

# Usage
defmodule MyApp.Accounts do
  def send_welcome_email(user) do
    mailer = Application.get_env(:my_app, :mailer)
    mailer.send(user.email, "Welcome!", "...")
  end
end
```

## Behavior + Default Implementation

```elixir
defmodule Worker do
  @callback process(term()) :: {:ok, term()} | {:error, term()}
  @callback timeout() :: pos_integer()

  @optional_callbacks timeout: 0

  defmacro __using__(_opts) do
    quote do
      @behaviour Worker

      # Default implementation
      def timeout, do: 5000

      defoverridable timeout: 0
    end
  end
end

defmodule MyWorker do
  use Worker

  @impl Worker
  def process(data) do
    {:ok, data}
  end

  # Uses default timeout: 5000
end

defmodule SlowWorker do
  use Worker

  @impl Worker
  def process(data) do
    {:ok, data}
  end

  @impl Worker
  def timeout, do: 30_000  # Override default
end
```

---

## Exercises

### Exercise 1: Storage Behavior
```elixir
# Define a Storage behavior with:
# - get(key) :: {:ok, value} | :not_found
# - put(key, value) :: :ok
# - delete(key) :: :ok
# Implement for ETS and Map

defmodule Storage do
  @callback get(key :: term()) :: {:ok, term()} | :not_found
  # ... more callbacks
end
```

### Exercise 2: HTTP Client
```elixir
# Define HTTPClient behavior
# Create implementations for:
# - Production (using HTTPoison or Req)
# - Test (returns mock responses)

defmodule HTTPClient do
  # Your callbacks here
end
```

### Exercise 3: Serializer
```elixir
# Define Serializer behavior with:
# - encode(term) :: {:ok, binary} | {:error, term}
# - decode(binary) :: {:ok, term} | {:error, term}
# - content_type() :: String.t()
# Implement for JSON, MessagePack, ETF
```

---

## Best Practices

1. **Use `@impl true`** - Catches errors at compile time
2. **Document callbacks** - Use `@doc` in behavior
3. **Mark optional callbacks** - `@optional_callbacks`
4. **Provide defaults via `use`** - When sensible
5. **Test against the behavior** - Not the implementation
