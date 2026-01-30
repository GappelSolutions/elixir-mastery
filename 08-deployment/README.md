# Deployment

**Usefulness: 10/10** - Get your app to production.

## Releases

Elixir releases are self-contained packages with everything needed to run.

### Creating a Release

```elixir
# mix.exs
def project do
  [
    releases: [
      my_app: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent]
      ]
    ]
  ]
end
```

```bash
# Build release
MIX_ENV=prod mix release

# Output in _build/prod/rel/my_app/
```

### Running the Release

```bash
# Start in foreground
_build/prod/rel/my_app/bin/my_app start

# Start as daemon
_build/prod/rel/my_app/bin/my_app daemon

# Connect to running node
_build/prod/rel/my_app/bin/my_app remote

# Stop
_build/prod/rel/my_app/bin/my_app stop

# Run migrations
_build/prod/rel/my_app/bin/my_app eval "MyApp.Release.migrate()"
```

## Runtime Configuration

```elixir
# config/runtime.exs (runs at boot, not compile)
import Config

config :my_app, MyApp.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :my_app, MyAppWeb.Endpoint,
  url: [host: System.get_env("HOST")],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# For releases
if config_env() == :prod do
  config :my_app, MyApp.Repo,
    ssl: true,
    ssl_opts: [verify: :verify_none]
end
```

## Release Commands

```elixir
# lib/my_app/release.ex
defmodule MyApp.Release do
  @app :my_app

  def migrate do
    load_app()
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
```

## Docker

```dockerfile
# Dockerfile
FROM elixir:1.15-alpine AS build

RUN apk add --no-cache build-base git

WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && mix local.rebar --force

# Install dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

# Compile dependencies
RUN MIX_ENV=prod mix deps.compile

# Copy source
COPY . .

# Compile and build release
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix assets.deploy
RUN MIX_ENV=prod mix release

# Runtime image
FROM alpine:3.18 AS app

RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app

COPY --from=build /app/_build/prod/rel/my_app ./

ENV HOME=/app
ENV MIX_ENV=prod
ENV PORT=4000

EXPOSE 4000

CMD ["bin/my_app", "start"]
```

```bash
# Build
docker build -t my_app .

# Run
docker run -p 4000:4000 \
  -e DATABASE_URL=postgres://... \
  -e SECRET_KEY_BASE=... \
  my_app
```

## Fly.io Deployment

```bash
# Install flyctl
brew install flyctl

# Login
fly auth login

# Create app
fly launch

# Deploy
fly deploy

# Open console
fly ssh console

# Run migrations
fly ssh console -C "/app/bin/my_app eval 'MyApp.Release.migrate()'"
```

```toml
# fly.toml
app = "my-app"
primary_region = "iad"

[build]
  dockerfile = "Dockerfile"

[env]
  PHX_HOST = "my-app.fly.dev"
  PORT = "8080"

[http_service]
  internal_port = 8080
  force_https = true

[[services.ports]]
  handlers = ["tls", "http"]
  port = 443
```

## Clustering

Connect multiple BEAM nodes.

### libcluster

```elixir
# mix.exs
{:libcluster, "~> 3.3"}

# config/runtime.exs
config :libcluster,
  topologies: [
    my_app: [
      strategy: Cluster.Strategy.Kubernetes.DNS,
      config: [
        service: "my-app-headless",
        application_name: "my_app"
      ]
    ]
  ]

# application.ex
children = [
  {Cluster.Supervisor, [
    Application.get_env(:libcluster, :topologies),
    [name: MyApp.ClusterSupervisor]
  ]},
  # ... other children
]
```

### Fly.io Clustering

```elixir
# config/runtime.exs
config :libcluster,
  topologies: [
    fly6pn: [
      strategy: Cluster.Strategy.DNSPoll,
      config: [
        polling_interval: 5_000,
        query: "#{System.get_env("FLY_APP_NAME")}.internal",
        node_basename: System.get_env("FLY_APP_NAME")
      ]
    ]
  ]

# rel/env.sh.eex
export RELEASE_DISTRIBUTION=name
export RELEASE_NODE="${FLY_APP_NAME}@${FLY_PRIVATE_IP}"
```

## Health Checks

```elixir
# lib/my_app_web/controllers/health_controller.ex
defmodule MyAppWeb.HealthController do
  use MyAppWeb, :controller

  def index(conn, _params) do
    checks = %{
      database: check_database(),
      memory: check_memory(),
      load: check_load()
    }

    status = if Enum.all?(checks, fn {_, v} -> v.healthy end), do: 200, else: 503
    json(conn, %{status: status, checks: checks})
  end

  defp check_database do
    try do
      MyApp.Repo.query!("SELECT 1")
      %{healthy: true}
    rescue
      _ -> %{healthy: false, error: "Database unreachable"}
    end
  end

  defp check_memory do
    memory = :erlang.memory(:total) / 1_000_000
    %{healthy: memory < 1000, memory_mb: memory}
  end

  defp check_load do
    %{healthy: true, scheduler_usage: :scheduler.utilization(1)}
  end
end
```

## Telemetry & Metrics

```elixir
# mix.exs
{:telemetry_metrics, "~> 0.6"},
{:telemetry_poller, "~> 1.0"},
{:prom_ex, "~> 1.8"}  # For Prometheus

# lib/my_app_web/telemetry.ex
defmodule MyAppWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      counter("phoenix.endpoint.start.system_time"),
      summary("phoenix.endpoint.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.router_dispatch.stop.duration", tags: [:route]),
      counter("my_app.repo.query.total_time"),
      last_value("vm.memory.total", unit: :byte)
    ]
  end

  defp periodic_measurements do
    [
      {MyApp.Metrics, :measure_users, []}
    ]
  end
end
```

---

## Exercises

### Exercise 1: Multi-Stage Docker
```dockerfile
# Build a minimal Docker image:
# - Multi-stage build
# - Alpine-based runtime
# - Under 50MB final size
```

### Exercise 2: Blue-Green Deployment
```elixir
# Implement blue-green deployment:
# - Run two versions simultaneously
# - Health check new version
# - Switch traffic atomically
```

### Exercise 3: Distributed Session Store
```elixir
# Replace cookie sessions with:
# - ETS-backed sessions
# - Synced across cluster
# - Survives node restarts
```

---

## Checklist

- [ ] Environment variables for secrets
- [ ] Database migrations automated
- [ ] Health check endpoint
- [ ] Logging configured
- [ ] Error tracking (Sentry, etc.)
- [ ] Metrics/monitoring
- [ ] SSL/TLS configured
- [ ] Rate limiting
- [ ] Backup strategy
- [ ] Rollback procedure tested
