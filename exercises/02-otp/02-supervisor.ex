# Supervisor Exercises
# Run: elixir exercises/02-otp/02-supervisor.ex

# =============================================================================
# Exercise 1: Basic Supervision Tree
# =============================================================================
# Create a supervision tree:
# RootSupervisor (:one_for_one)
#   ├── Counter (GenServer)
#   └── Logger (GenServer)
#
# Counter: increment/0, get/0
# Logger: log(message) - prints with timestamp

defmodule Counter do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  def increment, do: GenServer.cast(__MODULE__, :increment)
  def get, do: GenServer.call(__MODULE__, :get)

  @impl true
  def init(n), do: {:ok, n}

  @impl true
  def handle_cast(:increment, n), do: {:noreply, n + 1}

  @impl true
  def handle_call(:get, _from, n), do: {:reply, n, n}
end

defmodule Logger do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def log(message) do
    :todo
  end

  @impl true
  def init(_), do: {:ok, []}

  # Implement handle_cast for logging
end

defmodule RootSupervisor do
  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      # Define children here
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

# =============================================================================
# Exercise 2: Worker Pool with DynamicSupervisor
# =============================================================================
# Create a pool of workers that:
# - Has a configurable number of workers
# - Workers process jobs from a queue
# - If a worker crashes, it restarts and picks up new work

defmodule WorkerPool do
  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_worker do
    :todo
  end

  def process(job) do
    # Send job to an available worker
    :todo
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end

defmodule Worker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(_) do
    {:ok, :idle}
  end

  @impl true
  def handle_cast({:process, job, reply_to}, _state) do
    # Simulate work
    result = job.()
    send(reply_to, {:result, result})
    {:noreply, :idle}
  end
end

# =============================================================================
# Exercise 3: Circuit Breaker
# =============================================================================
# Implement a circuit breaker pattern:
# - Tracks failures for a service
# - After N failures, "opens" the circuit (rejects calls immediately)
# - After timeout, allows one test call
# - If test succeeds, close circuit; if fails, stay open

defmodule CircuitBreaker do
  use GenServer

  # States: :closed, :open, :half_open

  def start_link(opts) do
    # opts: failure_threshold, reset_timeout_ms
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def call(fun) do
    # Returns {:ok, result} or {:error, :circuit_open} or {:error, reason}
    :todo
  end

  @impl true
  def init(opts) do
    state = %{
      status: :closed,
      failures: 0,
      threshold: Keyword.get(opts, :failure_threshold, 5),
      timeout: Keyword.get(opts, :reset_timeout_ms, 5000)
    }
    {:ok, state}
  end

  # Implement handle_call for :call
  # Implement handle_info for :try_reset (timer)
end

# =============================================================================
# Tests
# =============================================================================

ExUnit.start(auto_run: false)

defmodule SupervisorTest do
  use ExUnit.Case

  describe "Exercise 1 - Basic Supervision" do
    setup do
      {:ok, _} = RootSupervisor.start_link()
      on_exit(fn ->
        if Process.whereis(RootSupervisor), do: Supervisor.stop(RootSupervisor)
      end)
      :ok
    end

    test "counter works" do
      Counter.increment()
      Counter.increment()
      assert Counter.get() == 2
    end

    test "counter restarts on crash" do
      Counter.increment()
      assert Counter.get() == 1

      # Kill the counter
      Process.exit(Process.whereis(Counter), :kill)
      Process.sleep(50)

      # Should be restarted with initial state
      assert Counter.get() == 0
    end
  end

  describe "Exercise 3 - Circuit Breaker" do
    setup do
      {:ok, _} = CircuitBreaker.start_link(failure_threshold: 3, reset_timeout_ms: 100)
      on_exit(fn -> GenServer.stop(CircuitBreaker) end)
      :ok
    end

    test "allows calls when closed" do
      assert {:ok, 42} = CircuitBreaker.call(fn -> 42 end)
    end

    test "opens after threshold failures" do
      Enum.each(1..3, fn _ ->
        CircuitBreaker.call(fn -> raise "error" end)
      end)

      assert {:error, :circuit_open} = CircuitBreaker.call(fn -> 42 end)
    end

    test "allows retry after timeout" do
      Enum.each(1..3, fn _ ->
        CircuitBreaker.call(fn -> raise "error" end)
      end)

      Process.sleep(150)

      # Should allow one test call
      assert {:ok, 42} = CircuitBreaker.call(fn -> 42 end)
    end
  end
end

ExUnit.run()
