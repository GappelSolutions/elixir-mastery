# Phoenix Framework

The web framework that makes real-time the default.

## Why Phoenix

- **Speed** - Microsecond response times
- **Reliability** - Millions of connections on a single server
- **Real-time by default** - Channels and LiveView built-in
- **Developer experience** - Hot reload, clear errors, excellent docs

## Learning Order

1. [Router & Pipelines](01-router.md)
2. [Controllers](02-controllers.md)
3. [Views & Templates](03-views.md)
4. [Plugs](04-plugs.md)
5. [Contexts](05-contexts.md)
6. [JSON APIs](06-json-apis.md)

## Project Structure

```
my_app/
├── lib/
│   ├── my_app/              # Business logic
│   │   ├── accounts/        # Context
│   │   │   ├── user.ex      # Schema
│   │   │   └── accounts.ex  # Context module
│   │   ├── application.ex   # OTP Application
│   │   └── repo.ex          # Database
│   └── my_app_web/          # Web layer
│       ├── controllers/
│       ├── components/      # HEEx components
│       ├── live/           # LiveView
│       ├── router.ex
│       ├── endpoint.ex
│       └── telemetry.ex
├── priv/
│   ├── repo/migrations/
│   └── static/
├── test/
├── config/
└── mix.exs
```

## Quick Start

```bash
# Create new project
mix phx.new my_app

# Create without Ecto (database)
mix phx.new my_app --no-ecto

# Create API-only
mix phx.new my_app --no-html --no-assets

cd my_app

# Setup database
mix ecto.setup

# Start server
mix phx.server
# or
iex -S mix phx.server  # With IEx shell
```

## Request Flow

```
Request
   ↓
Endpoint (Plug pipeline)
   ↓
Router (match route, apply pipeline)
   ↓
Plugs (middleware: auth, session, etc.)
   ↓
Controller (handle request)
   ↓
Context (business logic)
   ↓
View/Template or JSON
   ↓
Response
```

## Key Concepts

### Endpoint

Entry point for all requests. Configures plugs that run for every request.

```elixir
defmodule MyAppWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :my_app

  plug Plug.Static, at: "/", from: :my_app
  plug Plug.RequestId
  plug Plug.Logger
  plug Phoenix.LiveReloader  # Dev only
  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json]
  plug Plug.Session, store: :cookie
  plug MyAppWeb.Router
end
```

### Router

Maps URLs to controllers.

```elixir
defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyAppWeb do
    pipe_through :browser

    get "/", PageController, :home
    resources "/users", UserController
  end

  scope "/api", MyAppWeb.API do
    pipe_through :api

    resources "/posts", PostController, except: [:new, :edit]
  end
end
```

### Controller

Handles requests, delegates to context, renders response.

```elixir
defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  alias MyApp.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created!")
        |> redirect(to: ~p"/users/#{user}")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
```

### Context

Encapsulates business logic. The public API to a domain.

```elixir
defmodule MyApp.Accounts do
  alias MyApp.Repo
  alias MyApp.Accounts.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
```

---

## Generators

Phoenix generates boilerplate.

```bash
# Generate HTML resource
mix phx.gen.html Accounts User users name:string email:string

# Generate JSON API resource
mix phx.gen.json Accounts User users name:string email:string

# Generate context with schema only (no web)
mix phx.gen.context Accounts User users name:string email:string

# Generate schema only
mix phx.gen.schema Accounts.User users name:string email:string

# Generate LiveView resource
mix phx.gen.live Accounts User users name:string email:string

# Generate authentication
mix phx.gen.auth Accounts User users
```

---

## Development Commands

```bash
# Start with IEx
iex -S mix phx.server

# Run migrations
mix ecto.migrate

# Rollback
mix ecto.rollback

# Reset database
mix ecto.reset

# Generate migration
mix ecto.gen.migration add_users_table

# Routes
mix phx.routes

# Compile and show warnings as errors
mix compile --warnings-as-errors
```
