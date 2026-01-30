# Phoenix Channels

**Usefulness: 9/10** - Real-time bidirectional communication over WebSockets.

Channels provide soft real-time functionality. Chat, notifications, live updates, multiplayer games.

## How It Works

```
Browser                    Server
   │                          │
   ├── WebSocket Connect ────>│
   │                          │
   ├── join("room:lobby") ───>│ Channel.join
   │<── {:ok, socket} ────────│
   │                          │
   ├── push("new_msg", data)─>│ handle_in
   │<── broadcast ────────────│
   │                          │
```

## Socket Setup

```elixir
# lib/my_app_web/channels/user_socket.ex
defmodule MyAppWeb.UserSocket do
  use Phoenix.Socket

  channel "room:*", MyAppWeb.RoomChannel
  channel "user:*", MyAppWeb.UserChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case verify_token(token) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _} ->
        :error
    end
  end

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
```

## Channel Implementation

```elixir
defmodule MyAppWeb.RoomChannel do
  use MyAppWeb, :channel

  @impl true
  def join("room:" <> room_id, _params, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :room_id, room_id)}
  end

  @impl true
  def handle_info(:after_join, socket) do
    push(socket, "presence_state", get_presence(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_message", %{"body" => body}, socket) do
    broadcast!(socket, "new_message", %{
      body: body,
      user_id: socket.assigns.user_id
    })
    {:noreply, socket}
  end

  @impl true
  def handle_in("typing", _params, socket) do
    broadcast_from!(socket, "user_typing", %{
      user_id: socket.assigns.user_id
    })
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    # Cleanup when user leaves
    :ok
  end
end
```

## Client-Side (JavaScript)

```javascript
import { Socket } from "phoenix"

let socket = new Socket("/socket", {
  params: { token: window.userToken }
})

socket.connect()

let channel = socket.channel("room:lobby", {})

channel.join()
  .receive("ok", resp => console.log("Joined!", resp))
  .receive("error", resp => console.log("Failed to join", resp))

// Send messages
channel.push("new_message", { body: "Hello!" })

// Receive messages
channel.on("new_message", payload => {
  console.log("Message:", payload.body)
})

// Handle errors
channel.onError(() => console.log("Channel error"))
channel.onClose(() => console.log("Channel closed"))
```

## Broadcasting

```elixir
# To all subscribers of topic (including sender)
broadcast!(socket, "event", %{data: "value"})

# To all except sender
broadcast_from!(socket, "event", %{data: "value"})

# To specific socket
push(socket, "event", %{data: "value"})

# From anywhere in your app
MyAppWeb.Endpoint.broadcast("room:lobby", "event", %{data: "value"})
MyAppWeb.Endpoint.broadcast_from(self(), "room:lobby", "event", %{})
```

## Presence

Track who's online in real-time.

```elixir
defmodule MyAppWeb.Presence do
  use Phoenix.Presence,
    otp_app: :my_app,
    pubsub_server: MyApp.PubSub
end

# In channel
def handle_info(:after_join, socket) do
  {:ok, _} = MyAppWeb.Presence.track(socket, socket.assigns.user_id, %{
    online_at: System.system_time(:second)
  })
  push(socket, "presence_state", MyAppWeb.Presence.list(socket))
  {:noreply, socket}
end
```

```javascript
// Client
import { Presence } from "phoenix"

let presence = new Presence(channel)

presence.onSync(() => {
  let users = presence.list((id, { metas }) => ({ id, metas }))
  console.log("Online:", users)
})
```

## Intercepts

Modify outgoing messages per-socket.

```elixir
intercept ["new_message"]

@impl true
def handle_out("new_message", payload, socket) do
  if blocked?(socket.assigns.user_id, payload.from_id) do
    {:noreply, socket}  # Don't send
  else
    push(socket, "new_message", payload)
    {:noreply, socket}
  end
end
```

## Authentication

```elixir
# Generate token in controller
def create_token(conn, _) do
  token = Phoenix.Token.sign(conn, "user socket", current_user(conn).id)
  json(conn, %{token: token})
end

# Verify in socket
def connect(%{"token" => token}, socket, _connect_info) do
  case Phoenix.Token.verify(socket, "user socket", token, max_age: 86400) do
    {:ok, user_id} -> {:ok, assign(socket, :user_id, user_id)}
    {:error, _} -> :error
  end
end
```

---

## Exercises

### Exercise 1: Chat Room
```elixir
# Build a chat with:
# - Multiple rooms
# - Presence (who's online)
# - Typing indicators
# - Message history

defmodule ChatChannel do
  # Your code here
end
```

### Exercise 2: Live Notifications
```elixir
# Real-time notifications:
# - User-specific channel
# - Push from anywhere in app
# - Read/unread state

defmodule NotificationChannel do
  # Your code here
end
```

### Exercise 3: Multiplayer Game
```elixir
# Simple real-time game:
# - Game rooms
# - Turn-based or real-time state sync
# - Spectator mode
```

---

## Channel vs LiveView

| Channels | LiveView |
|----------|----------|
| Custom protocol | HTML over WebSocket |
| JavaScript required | Minimal JS |
| Full control | Server-rendered UI |
| Games, chat | CRUD, dashboards |
| Manual state sync | Automatic DOM updates |
