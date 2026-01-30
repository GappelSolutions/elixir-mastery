# LiveView

**The killer feature.** Real-time, server-rendered UIs without JavaScript.

## The Paradigm Shift

Traditional SPA:
```
Browser <-> API <-> Server
   JS        JSON    Business Logic
```

LiveView:
```
Browser <-> WebSocket <-> Server
  Minimal JS    Diffs    Everything
```

State lives on the server. UI updates via WebSocket diffs. No API layer. No client-side state management.

## Learning Order

1. [Lifecycle](01-lifecycle.md)
2. [Events & Assigns](02-events.md)
3. [LiveComponents](03-components.md)
4. [Streams](04-streams.md)
5. [JS Commands](05-js-commands.md)
6. [Uploads](06-uploads.md)
7. [PubSub Integration](07-pubsub.md)

## Basic LiveView

```elixir
defmodule MyAppWeb.CounterLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply, update(socket, :count, &(&1 - 1))}
  end

  def render(assigns) do
    ~H"""
    <div class="counter">
      <h1>Count: <%= @count %></h1>
      <button phx-click="decrement">-</button>
      <button phx-click="increment">+</button>
    </div>
    """
  end
end
```

Router:
```elixir
live "/counter", CounterLive
```

That's it. Real-time counter with zero JavaScript.

## Lifecycle

```
User navigates to /counter
         ↓
mount/3 (dead render for SEO)
         ↓
HTML sent to browser
         ↓
WebSocket connects
         ↓
mount/3 (again, connected)
         ↓
handle_params/3
         ↓
render/1 (live updates from here)
```

### mount/3

```elixir
def mount(params, session, socket) do
  # params: URL params
  # session: Session data
  # socket: The LiveView socket

  if connected?(socket) do
    # Only runs when WebSocket connected
    subscribe_to_updates()
  end

  {:ok, assign(socket, data: [])}
end
```

### handle_params/3

Called on navigation (including initial and live_patch).

```elixir
def handle_params(%{"id" => id}, _uri, socket) do
  post = Blog.get_post!(id)
  {:noreply, assign(socket, post: post, page_title: post.title)}
end
```

### render/1

```elixir
def render(assigns) do
  ~H"""
  <div>
    <%= @data %>
  </div>
  """
end
```

## Events

### Click Events

```elixir
<button phx-click="save">Save</button>
<button phx-click="delete" phx-value-id={@item.id}>Delete</button>

def handle_event("save", _params, socket) do
  {:noreply, socket}
end

def handle_event("delete", %{"id" => id}, socket) do
  {:noreply, socket}
end
```

### Form Events

```elixir
<.form for={@form} phx-submit="save" phx-change="validate">
  <.input field={@form[:name]} label="Name" />
  <.button>Save</.button>
</.form>

def handle_event("validate", %{"user" => params}, socket) do
  changeset = User.changeset(%User{}, params)
  {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
end

def handle_event("save", %{"user" => params}, socket) do
  case Accounts.create_user(params) do
    {:ok, user} ->
      {:noreply,
       socket
       |> put_flash(:info, "Created!")
       |> push_navigate(to: ~p"/users/#{user}")}

    {:error, changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end
```

### Other Events

```elixir
phx-blur="event"        # Focus lost
phx-focus="event"       # Focus gained
phx-keydown="event"     # Key pressed
phx-keyup="event"       # Key released
phx-window-keydown      # Global key events
phx-window-focus        # Window focus
phx-window-blur         # Window blur
```

## Assigns

```elixir
# Set single assign
assign(socket, :count, 0)

# Set multiple
assign(socket, count: 0, name: "Alice")

# Update based on current value
update(socket, :count, &(&1 + 1))

# Temporary assigns (cleared after render, for large lists)
mount(_, _, socket) do
  {:ok, socket, temporary_assigns: [messages: []]}
end
```

## LiveComponents

Stateful components within a LiveView.

```elixir
defmodule MyAppWeb.CardComponent do
  use MyAppWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="card" id={@id}>
      <h2><%= @title %></h2>
      <button phx-click="like" phx-target={@myself}>Like</button>
      <span><%= @likes %> likes</span>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns) |> assign_new(:likes, fn -> 0 end)}
  end

  def handle_event("like", _, socket) do
    {:noreply, update(socket, :likes, &(&1 + 1))}
  end
end

# Usage in parent LiveView
~H"""
<.live_component module={CardComponent} id="card-1" title="My Card" />
"""
```

## Streams

Efficient handling of large collections.

```elixir
def mount(_, _, socket) do
  {:ok, stream(socket, :posts, Blog.list_posts())}
end

def render(assigns) do
  ~H"""
  <div id="posts" phx-update="stream">
    <div :for={{dom_id, post} <- @streams.posts} id={dom_id}>
      <%= post.title %>
    </div>
  </div>
  """
end

# Add item
stream_insert(socket, :posts, new_post)

# Remove item
stream_delete(socket, :posts, post)

# Update item
stream_insert(socket, :posts, updated_post)  # Same ID replaces
```

## Real-Time Updates

```elixir
def mount(_, _, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "posts")
  end
  {:ok, stream(socket, :posts, Blog.list_posts())}
end

def handle_info({:new_post, post}, socket) do
  {:noreply, stream_insert(socket, :posts, post, at: 0)}
end

# Somewhere else in your app
Phoenix.PubSub.broadcast(MyApp.PubSub, "posts", {:new_post, post})
```

## Navigation

```elixir
# Full page navigation (new LiveView mount)
push_navigate(socket, to: ~p"/posts")

# Patch (same LiveView, triggers handle_params)
push_patch(socket, to: ~p"/posts?page=2")

# In templates
<.link navigate={~p"/posts"}>Posts</.link>
<.link patch={~p"/posts?page=2"}>Page 2</.link>
```

---

## Exercises

### Exercise 1: Todo List
```elixir
# Build a todo list with:
# - Add/remove items
# - Toggle complete
# - Filter (all/active/completed)
# - Persist to database
# - Real-time sync across tabs
```

### Exercise 2: Live Search
```elixir
# Implement live search:
# - Debounce input (300ms)
# - Show loading state
# - Display results as user types
# - Handle empty state
```

### Exercise 3: Infinite Scroll
```elixir
# Implement infinite scroll:
# - Load initial page
# - Detect scroll to bottom (JS hook)
# - Load more items
# - Use streams for efficiency
```

### Exercise 4: Collaborative Editor
```elixir
# Build a collaborative text editor:
# - Multiple users can type
# - See others' cursors
# - Broadcast changes via PubSub
# - Handle conflicts
```

### Exercise 5: Dashboard
```elixir
# Real-time dashboard:
# - Multiple metrics updating independently
# - Charts (with JS hooks)
# - Refresh intervals
# - Pause/resume updates
```

---

## Performance Tips

1. **Use streams for lists** - Don't re-render entire list on changes
2. **Temporary assigns** - Clear large data after render
3. **Avoid assigns in comprehensions** - Can cause full re-render
4. **Debounce inputs** - `phx-debounce="300"`
5. **Lazy load** - Don't load everything on mount
