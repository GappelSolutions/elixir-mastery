# Elixir & Phoenix Mastery

A year-long curriculum to master every feature of Elixir, OTP, and Phoenix.

## Philosophy

- **Learn by building**, not by reading
- **Most useful first** - you'll be productive within weeks
- **Depth over breadth** - understand why, not just how
- **Break things intentionally** - the best way to understand fault tolerance

## Prerequisites

```bash
# Install Elixir (macOS)
brew install elixir

# Verify
elixir --version
iex  # Interactive Elixir shell (Ctrl+C twice to exit)

# Install Phoenix
mix local.hex
mix archive.install hex phx_new
```

## Directory Structure

```
00-roadmap/       # Learning path and milestones
01-elixir-core/   # Language fundamentals
02-otp/           # OTP behaviors and fault tolerance
03-phoenix/       # Web framework core
04-ecto/          # Database layer
05-liveview/      # Real-time server-rendered UI
06-channels/      # WebSockets and real-time
07-testing/       # ExUnit and property testing
08-deployment/    # Releases and production
09-advanced/      # Distributed systems, NIFs, ports
10-metaprogramming/ # Macros and compile-time magic
exercises/        # Standalone projects
```

## Time Investment

| Phase | Duration | Focus |
|-------|----------|-------|
| Foundation | Months 1-2 | Elixir core + basic OTP |
| Application | Months 3-4 | Phoenix + Ecto |
| Real-time | Months 5-6 | LiveView + Channels |
| Production | Months 7-8 | Testing + Deployment |
| Mastery | Months 9-12 | Advanced + Metaprogramming |

## Start Here

1. [The Roadmap](00-roadmap/ROADMAP.md)
2. [Elixir Core](01-elixir-core/README.md)

---

*"The goal isn't to learn Elixir. It's to think in processes."*
