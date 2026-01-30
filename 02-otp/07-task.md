# Task

**Usefulness: 9/10** - Simple async operations without the GenServer ceremony.

Task wraps a function to execute asynchronously. Perfect for one-off concurrent work.

## Basic Usage

### async/await

```elixir
# Start async task
task = Task.async(fn -> expensive_computation() end)

# Do other work...

# Wait for result (blocks)
result = Task.await(task)

# With timeout (default 5000ms)
result = Task.await(task, 10_000)
```

### Fire and Forget

```elixir
# Don't care about result
Task.start(fn -> send_email(user) end)

# Supervised (preferred)
Task.Supervisor.start_child(MyApp.TaskSupervisor, fn ->
  send_email(user)
end)
```

## Multiple Tasks

### await_many

```elixir
tasks = [
  Task.async(fn -> fetch_users() end),
  Task.async(fn -> fetch_posts() end),
  Task.async(fn -> fetch_comments() end)
]

[users, posts, comments] = Task.await_many(tasks)
```

### yield_many

Non-blocking check on multiple tasks.

```elixir
tasks = Enum.map(urls, fn url ->
  Task.async(fn -> fetch(url) end)
end)

# Check results, timeout after 5s
results = Task.yield_many(tasks, 5000)

Enum.map(results, fn {task, result} ->
  case result do
    {:ok, value} -> value
    {:exit, reason} -> {:error, reason}
    nil ->
      Task.shutdown(task)
      {:error, :timeout}
  end
end)
```

## async_stream

Process collections concurrently with backpressure.

```elixir
urls
|> Task.async_stream(fn url -> fetch(url) end)
|> Enum.map(fn {:ok, result} -> result end)

# With options
users
|> Task.async_stream(
  fn user -> send_email(user) end,
  max_concurrency: 10,    # Limit parallel tasks
  timeout: 30_000,        # Per-task timeout
  on_timeout: :kill_task  # What to do on timeout
)
|> Enum.to_list()
```

### Ordered vs Unordered

```elixir
# Results in order (default)
Task.async_stream(items, &process/1, ordered: true)

# Results as they complete (faster for variable-time tasks)
Task.async_stream(items, &process/1, ordered: false)
```

## Supervised Tasks

Always use Task.Supervisor in production.

```elixir
# In supervision tree
children = [
  {Task.Supervisor, name: MyApp.TaskSupervisor}
]

# Usage
Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
  do_work()
end)

# With options
Task.Supervisor.async(MyApp.TaskSupervisor, fn ->
  do_work()
end, shutdown: 10_000)

# async_stream with supervisor
Task.Supervisor.async_stream(MyApp.TaskSupervisor, items, &process/1)
```

## Task Module Functions

```elixir
# Start linked task
Task.async(fun)
Task.async(module, fun, args)

# Start unlinked task
Task.start(fun)
Task.start(module, fun, args)

# Start linked, ignore result
Task.start_link(fun)

# Wait for result
Task.await(task)
Task.await(task, timeout)

# Non-blocking check
Task.yield(task)
Task.yield(task, timeout)

# Kill task
Task.shutdown(task)
Task.shutdown(task, :brutal_kill)

# Multiple tasks
Task.await_many(tasks)
Task.yield_many(tasks)
```

## Linking Behavior

```elixir
# async - linked to caller
task = Task.async(fn -> raise "boom" end)
Task.await(task)  # Caller crashes

# start - not linked
Task.start(fn -> raise "boom" end)  # Caller unaffected

# start_link - linked but no result
Task.start_link(fn -> raise "boom" end)  # Caller crashes
```

## Error Handling

```elixir
# Task failures propagate
task = Task.async(fn -> raise "error" end)
Task.await(task)  # ** (RuntimeError) error

# Handle with yield
task = Task.async(fn -> raise "error" end)
case Task.yield(task) || Task.shutdown(task) do
  {:ok, result} -> {:ok, result}
  {:exit, reason} -> {:error, reason}
  nil -> {:error, :timeout}
end
```

---

## Exercises

### Exercise 1: Parallel HTTP Fetcher
```elixir
# Fetch multiple URLs in parallel with:
# - Max 5 concurrent requests
# - 10s timeout per request
# - Retry failed requests once

defmodule ParallelFetcher do
  def fetch_all(urls) do
    # Your code here
  end
end
```

### Exercise 2: Progress Tracker
```elixir
# Process items with progress reporting:
# - Process in parallel
# - Report progress every 10%
# - Handle failures gracefully

defmodule ProgressProcessor do
  def process_with_progress(items, callback) do
    # Your code here
  end
end
```

### Exercise 3: Timeout with Fallback
```elixir
# Execute with timeout and fallback:
# - Try primary function
# - If timeout, try fallback
# - If both timeout, return error

defmodule TimeoutFallback do
  def execute(primary_fn, fallback_fn, timeout) do
    # Your code here
  end
end
```

---

## When to Use Task vs GenServer

| Task | GenServer |
|------|-----------|
| One-off work | Long-running state |
| Parallel processing | Request/response |
| Fire and forget | Named processes |
| Simple async/await | Complex lifecycle |
