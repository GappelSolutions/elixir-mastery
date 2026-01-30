# Processes

**Usefulness: 10/10** - Everything in Elixir runs in processes.

Processes are NOT OS threads. They're lightweight (2KB initial), cheap to spawn (microseconds), and the BEAM can handle millions.

## Spawning Processes

```elixir
# Basic spawn
pid = spawn(fn -> IO.puts("Hello from process!") end)
# #PID<0.123.0>

# spawn with module/function/args
pid = spawn(IO, :puts, ["Hello!"])

# Check if alive
Process.alive?(pid)  # false (already finished)
```

## Current Process

```elixir
self()  # #PID<0.110.0>

# See process info
Process.info(self())
# [current_function: ..., initial_call: ..., status: :running, ...]
```

## Message Passing

Processes communicate by sending messages. Each process has a mailbox.

```elixir
# Send message (always succeeds, even if target doesn't exist)
send(self(), :hello)
send(self(), {:data, 42})

# Receive message
receive do
  :hello -> "Got hello"
  {:data, value} -> "Got data: #{value}"
end
```

### Receive with Timeout

```elixir
receive do
  msg -> msg
after
  5000 -> :timeout  # 5 seconds
end
```

### Selective Receive

Messages are processed in the order they match patterns, not arrival order.

```elixir
send(self(), :a)
send(self(), :b)
send(self(), :c)

receive do
  :c -> "got c first"  # Matches!
end
# Mailbox still has :a, :b
```

## Stateful Process

```elixir
defmodule Counter do
  def start(initial \\ 0) do
    spawn(fn -> loop(initial) end)
  end

  defp loop(count) do
    receive do
      :increment ->
        loop(count + 1)

      :decrement ->
        loop(count - 1)

      {:get, caller} ->
        send(caller, {:count, count})
        loop(count)

      :stop ->
        :ok  # Exit the loop
    end
  end
end

# Usage
counter = Counter.start(10)
send(counter, :increment)
send(counter, :increment)
send(counter, {:get, self()})
receive do
  {:count, n} -> n  # 12
end
```

## Process Links

Links create bidirectional crash propagation.

```elixir
# Spawned process crashes = current process crashes
spawn_link(fn -> raise "boom" end)
# ** (EXIT from #PID<0.110.0>) shell process exited...

# Spawn without link = isolated crash
spawn(fn -> raise "boom" end)
# Error is logged, but shell continues
```

### Trapping Exits

Convert exit signals to messages.

```elixir
Process.flag(:trap_exit, true)

pid = spawn_link(fn -> exit(:normal) end)

receive do
  {:EXIT, ^pid, reason} ->
    "Process exited with: #{inspect(reason)}"
end
```

## Process Monitoring

One-way watching. Monitor gets notified, doesn't crash.

```elixir
pid = spawn(fn -> :timer.sleep(100) end)
ref = Process.monitor(pid)

receive do
  {:DOWN, ^ref, :process, ^pid, reason} ->
    "Process died: #{reason}"
end
```

## Process Registration

Give processes names for easy access.

```elixir
pid = spawn(fn ->
  receive do
    msg -> IO.puts("Got: #{msg}")
  end
end)

Process.register(pid, :my_process)

send(:my_process, "Hello!")  # Works!
```

## Process Dictionary

Per-process key-value storage. Use sparingly!

```elixir
Process.put(:key, "value")
Process.get(:key)  # "value"
Process.get(:missing)  # nil
Process.get(:missing, "default")  # "default"
Process.delete(:key)
```

**Warning**: Process dictionary is hidden state. Makes testing and reasoning harder. Prefer explicit state passing.

---

## Process Patterns

### Request-Response

```elixir
defmodule Server do
  def call(server, request) do
    ref = make_ref()
    send(server, {self(), ref, request})
    receive do
      {^ref, response} -> response
    after
      5000 -> {:error, :timeout}
    end
  end
end
```

### Worker Pool

```elixir
defmodule Pool do
  def start(worker_count) do
    spawn(fn ->
      workers = for _ <- 1..worker_count do
        spawn_link(&worker_loop/0)
      end
      pool_loop(workers, :queue.new())
    end)
  end

  defp pool_loop([], queue) do
    receive do
      {:worker_ready, worker} ->
        case :queue.out(queue) do
          {{:value, {caller, ref, work}}, queue} ->
            send(worker, {:work, caller, ref, work})
            pool_loop([], queue)
          {:empty, _} ->
            pool_loop([worker], queue)
        end
    end
  end

  defp pool_loop([worker | rest], queue) do
    receive do
      {:work, caller, ref, work} ->
        send(worker, {:work, caller, ref, work})
        pool_loop(rest, queue)
      {:worker_ready, w} ->
        pool_loop([w, worker | rest], queue)
    end
  end

  defp worker_loop do
    receive do
      {:work, caller, ref, work} ->
        result = work.()
        send(caller, {ref, result})
        # Notify pool we're ready
    end
    worker_loop()
  end
end
```

---

## Exercises

### Exercise 1: Ping Pong
```elixir
# Create two processes that send messages back and forth
# Process A sends :ping to B
# Process B receives :ping, sends :pong to A
# Continue n times

defmodule PingPong do
  def start(n) do
    # Your code here
  end
end
```

### Exercise 2: Ring of Processes
```elixir
# Create N processes in a ring
# Send a message around the ring M times
# Measure total time

defmodule Ring do
  def benchmark(process_count, rounds) do
    # Your code here
  end
end
```

### Exercise 3: Simple Key-Value Store
```elixir
# Build a process that stores key-value pairs
# Support: put(pid, key, value), get(pid, key), delete(pid, key)

defmodule KV do
  def start, do: spawn(fn -> loop(%{}) end)

  def put(pid, key, value) do
    # Your code here
  end

  def get(pid, key) do
    # Your code here
  end

  defp loop(state) do
    # Your code here
  end
end
```

### Exercise 4: Process Monitor
```elixir
# Create a process that monitors a list of processes
# When any dies, log it and spawn a replacement

defmodule Monitor do
  def start(process_funs) do
    # process_funs is a list of 0-arity functions to spawn
  end
end
```

### Exercise 5: Timeout Server
```elixir
# Create a server that:
# - Accepts work items with deadlines
# - Processes them in deadline order
# - Cancels items that exceed deadline before processing

defmodule DeadlineServer do
  def start do
    # Your code here
  end

  def submit(server, work_fn, deadline_ms) do
    # Your code here
  end
end
```

---

## Gotchas

### Message Mailbox Overflow

```elixir
# BAD - messages pile up if not received
for _ <- 1..1_000_000 do
  send(some_process, :message)
end

# Check mailbox size
{:message_queue_len, len} = Process.info(pid, :message_queue_len)
```

### Receive Without After

```elixir
# This blocks forever if no message arrives
receive do
  msg -> msg
end

# Always consider timeout
receive do
  msg -> msg
after
  30_000 -> :timeout
end
```

### Process Leaks

```elixir
# BAD - orphan processes
def handle_request(data) do
  spawn(fn -> process(data) end)  # Who supervises this?
  :ok
end

# GOOD - supervised processes
def handle_request(data) do
  Task.Supervisor.start_child(MyApp.TaskSupervisor, fn ->
    process(data)
  end)
end
```
