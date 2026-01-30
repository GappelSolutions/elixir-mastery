# GenStage

**Usefulness: 7/10** - Backpressure and data pipelines. Use when you need flow control.

GenStage provides a way to build data pipelines with backpressure - consumers control how much data they receive.

## Concepts

- **Producer** - Emits events
- **Consumer** - Receives events
- **Producer-Consumer** - Both receives and emits

```
Producer --> ProducerConsumer --> Consumer
   (source)     (transform)       (sink)
```

## Basic Producer

```elixir
defmodule Counter do
  use GenStage

  def start_link(start) do
    GenStage.start_link(__MODULE__, start, name: __MODULE__)
  end

  @impl true
  def init(start) do
    {:producer, start}
  end

  @impl true
  def handle_demand(demand, counter) when demand > 0 do
    events = Enum.to_list(counter..(counter + demand - 1))
    {:noreply, events, counter + demand}
  end
end
```

## Basic Consumer

```elixir
defmodule Printer do
  use GenStage

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    {:consumer, :ok, subscribe_to: [Counter]}
  end

  @impl true
  def handle_events(events, _from, state) do
    Enum.each(events, &IO.inspect/1)
    {:noreply, [], state}
  end
end
```

## Producer-Consumer

```elixir
defmodule Doubler do
  use GenStage

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    {:producer_consumer, :ok, subscribe_to: [Counter]}
  end

  @impl true
  def handle_events(events, _from, state) do
    doubled = Enum.map(events, &(&1 * 2))
    {:noreply, doubled, state}
  end
end
```

## Subscription Options

```elixir
def init(:ok) do
  {:consumer, :ok,
    subscribe_to: [
      {Producer, min_demand: 50, max_demand: 100}
    ]}
end

# Or subscribe manually
def init(:ok) do
  {:consumer, :ok}
end

def handle_info(:subscribe, state) do
  GenStage.async_subscribe(self(), to: Producer, max_demand: 100)
  {:noreply, [], state}
end
```

## Dispatcher Types

### DemandDispatcher (default)

Sends events to consumers based on demand.

```elixir
def init(_) do
  {:producer, state, dispatcher: GenStage.DemandDispatcher}
end
```

### BroadcastDispatcher

Sends all events to all consumers.

```elixir
def init(_) do
  {:producer, state, dispatcher: GenStage.BroadcastDispatcher}
end
```

### PartitionDispatcher

Partitions events by key.

```elixir
def init(_) do
  {:producer, state,
    dispatcher: {GenStage.PartitionDispatcher, partitions: 4, hash: &hash/1}}
end

defp hash(event), do: {event, :erlang.phash2(event.key, 4)}
```

## Flow - High-Level GenStage

Flow provides a simpler API for parallel data processing.

```elixir
# Add to mix.exs: {:flow, "~> 1.0"}

# Basic parallel processing
1..1000
|> Flow.from_enumerable()
|> Flow.map(&(&1 * 2))
|> Flow.filter(&(rem(&1, 3) == 0))
|> Enum.to_list()

# Partitioned processing
orders
|> Flow.from_enumerable()
|> Flow.partition(key: & &1.customer_id)
|> Flow.reduce(fn -> %{} end, fn order, acc ->
  Map.update(acc, order.customer_id, order.total, &(&1 + order.total))
end)
|> Enum.to_list()

# From producer
Flow.from_stages([Producer])
|> Flow.map(&process/1)
|> Flow.run()
```

## Flow Windows

Process data in time or count windows.

```elixir
Flow.from_enumerable(events)
|> Flow.partition(window: Flow.Window.count(100))
|> Flow.reduce(fn -> 0 end, fn _, acc -> acc + 1 end)
|> Flow.emit(:state)
|> Enum.to_list()
```

---

## Exercises

### Exercise 1: File Processor Pipeline
```elixir
# Build a pipeline that:
# - Reads lines from files (producer)
# - Parses JSON (producer-consumer)
# - Writes to database (consumer)
# With backpressure handling
```

### Exercise 2: Rate-Limited API Consumer
```elixir
# Consume from an API with:
# - Rate limiting (N requests/second)
# - Retry on failure
# - Backpressure when processing is slow
```

---

## When to Use GenStage/Flow

- Processing large datasets
- Need backpressure (prevent memory overflow)
- Event streaming
- ETL pipelines
- Rate limiting

## When NOT to Use

- Simple parallel processing (use Task.async_stream)
- Small datasets (Enum is fine)
- When you don't need backpressure
