# GenServer Exercises
# Run: elixir exercises/02-otp/01-genserver.ex

# =============================================================================
# Exercise 1: Stack
# =============================================================================
# Implement a stack GenServer with:
# - push(item)
# - pop() -> item (or :empty)
# - peek() -> item (or :empty)
# - size() -> integer

defmodule Stack do
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def push(pid, item) do
    :todo
  end

  def pop(pid) do
    :todo
  end

  def peek(pid) do
    :todo
  end

  def size(pid) do
    :todo
  end

  # Server Callbacks

  @impl true
  def init(_) do
    {:ok, []}
  end

  # Add handle_call and handle_cast implementations
end

# =============================================================================
# Exercise 2: Rate Limiter
# =============================================================================
# Implement a rate limiter:
# - allow?(key) -> true if under limit, false otherwise
# - Configure: max requests per time window

defmodule RateLimiter do
  use GenServer

  def start_link(opts) do
    # opts: max_requests, window_ms
    max = Keyword.fetch!(opts, :max_requests)
    window = Keyword.fetch!(opts, :window_ms)
    GenServer.start_link(__MODULE__, {max, window}, name: __MODULE__)
  end

  def allow?(key) do
    :todo
  end

  @impl true
  def init({max, window}) do
    # State: %{max: max, window: window, requests: %{}}
    {:ok, %{max: max, window: window, requests: %{}}}
  end

  # Implement handle_call for :allow?
  # Hint: use handle_info for cleanup with Process.send_after
end

# =============================================================================
# Exercise 3: Pub/Sub
# =============================================================================
# Simple publish-subscribe:
# - subscribe(topic) - current process subscribes
# - unsubscribe(topic)
# - publish(topic, message) - sends to all subscribers

defmodule PubSub do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def subscribe(topic) do
    :todo
  end

  def unsubscribe(topic) do
    :todo
  end

  def publish(topic, message) do
    :todo
  end

  @impl true
  def init(_) do
    {:ok, %{}}  # %{topic => [pid, ...]}
  end

  # Implement callbacks
  # Hint: Monitor subscribers to clean up on death
end

# =============================================================================
# Exercise 4: Cache with TTL
# =============================================================================
# Key-value cache with expiration:
# - put(key, value, ttl_ms)
# - get(key) -> {:ok, value} | :not_found
# - Automatic cleanup of expired entries

defmodule TTLCache do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def put(key, value, ttl_ms) do
    :todo
  end

  def get(key) do
    :todo
  end

  @impl true
  def init(_) do
    # State: %{key => {value, expires_at}}
    {:ok, %{}}
  end

  # Implement callbacks
  # Hint: Store expiration timestamp, check on get
  # Bonus: Use handle_info with Process.send_after for cleanup
end

# =============================================================================
# Tests
# =============================================================================

ExUnit.start(auto_run: false)

defmodule GenServerTest do
  use ExUnit.Case

  describe "Exercise 1 - Stack" do
    setup do
      {:ok, pid} = Stack.start_link()
      %{stack: pid}
    end

    test "push and pop", %{stack: stack} do
      Stack.push(stack, 1)
      Stack.push(stack, 2)
      assert Stack.pop(stack) == 2
      assert Stack.pop(stack) == 1
      assert Stack.pop(stack) == :empty
    end

    test "peek doesn't remove", %{stack: stack} do
      Stack.push(stack, 1)
      assert Stack.peek(stack) == 1
      assert Stack.peek(stack) == 1
    end

    test "size", %{stack: stack} do
      assert Stack.size(stack) == 0
      Stack.push(stack, 1)
      Stack.push(stack, 2)
      assert Stack.size(stack) == 2
    end
  end

  describe "Exercise 2 - Rate Limiter" do
    setup do
      # Allow 3 requests per 100ms
      {:ok, _} = RateLimiter.start_link(max_requests: 3, window_ms: 100)
      on_exit(fn -> GenServer.stop(RateLimiter) end)
      :ok
    end

    test "allows requests under limit" do
      assert RateLimiter.allow?("user1") == true
      assert RateLimiter.allow?("user1") == true
      assert RateLimiter.allow?("user1") == true
    end

    test "blocks requests over limit" do
      assert RateLimiter.allow?("user2") == true
      assert RateLimiter.allow?("user2") == true
      assert RateLimiter.allow?("user2") == true
      assert RateLimiter.allow?("user2") == false
    end

    test "separate limits per key" do
      Enum.each(1..3, fn _ -> RateLimiter.allow?("user3") end)
      assert RateLimiter.allow?("user3") == false
      assert RateLimiter.allow?("user4") == true
    end
  end

  describe "Exercise 3 - PubSub" do
    setup do
      {:ok, _} = PubSub.start_link([])
      on_exit(fn -> GenServer.stop(PubSub) end)
      :ok
    end

    test "receives published messages" do
      PubSub.subscribe("news")
      PubSub.publish("news", "hello")

      assert_receive {:pubsub, "news", "hello"}
    end

    test "doesn't receive after unsubscribe" do
      PubSub.subscribe("news")
      PubSub.unsubscribe("news")
      PubSub.publish("news", "hello")

      refute_receive {:pubsub, "news", "hello"}, 50
    end

    test "multiple subscribers" do
      parent = self()

      spawn(fn ->
        PubSub.subscribe("news")
        send(parent, :subscribed)
        receive do
          msg -> send(parent, {:child, msg})
        end
      end)

      receive do: (:subscribed -> :ok)
      PubSub.subscribe("news")
      PubSub.publish("news", "hello")

      assert_receive {:pubsub, "news", "hello"}
      assert_receive {:child, {:pubsub, "news", "hello"}}
    end
  end

  describe "Exercise 4 - TTL Cache" do
    setup do
      {:ok, _} = TTLCache.start_link([])
      on_exit(fn -> GenServer.stop(TTLCache) end)
      :ok
    end

    test "stores and retrieves values" do
      TTLCache.put("key", "value", 1000)
      assert TTLCache.get("key") == {:ok, "value"}
    end

    test "returns not_found for missing" do
      assert TTLCache.get("missing") == :not_found
    end

    test "expires after TTL" do
      TTLCache.put("key", "value", 50)
      assert TTLCache.get("key") == {:ok, "value"}
      Process.sleep(60)
      assert TTLCache.get("key") == :not_found
    end
  end
end

ExUnit.run()
