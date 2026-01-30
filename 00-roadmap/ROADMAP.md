# The Complete Roadmap

Everything in Elixir/Phoenix, ordered by usefulness and practical impact.

## Tier 1: Daily Essentials (Use Every Single Day)

These features form the backbone of all Elixir code.

### Week 1-2: Pattern Matching & Data
- [ ] Pattern matching in assignments
- [ ] Pattern matching in function heads
- [ ] Guards (`when` clauses)
- [ ] Tuples, Lists, Maps, Keyword lists
- [ ] Structs
- [ ] The pipe operator `|>`
- [ ] String interpolation and sigils

### Week 3-4: Functions & Modules
- [ ] Anonymous functions
- [ ] Named functions
- [ ] Private functions (`defp`)
- [ ] Module attributes (`@doc`, `@moduledoc`, `@spec`)
- [ ] Importing, aliasing, requiring
- [ ] Behaviors and protocols

### Week 5-6: Control Flow
- [ ] `case` expressions
- [ ] `cond` expressions
- [ ] `with` expressions (monadic error handling)
- [ ] `if`/`unless` (rarely needed)
- [ ] Recursion and tail-call optimization
- [ ] Comprehensions (`for`)

### Week 7-8: Concurrency Basics
- [ ] Spawning processes
- [ ] Sending and receiving messages
- [ ] Process linking and monitoring
- [ ] Process dictionaries (and why to avoid them)
- [ ] `Task` for simple async work
- [ ] `Agent` for simple state

---

## Tier 2: Core Competency (Use Most Days)

### Month 3: OTP Behaviors
- [ ] GenServer (the workhorse)
- [ ] Supervisor (fault tolerance)
- [ ] Application (your app's entry point)
- [ ] DynamicSupervisor
- [ ] Registry
- [ ] GenStage (backpressure)

### Month 4: Phoenix Core
- [ ] Router and pipelines
- [ ] Controllers
- [ ] Views and templates (HEEx)
- [ ] Plugs (middleware)
- [ ] Contexts (domain organization)
- [ ] JSON APIs

### Month 5: Ecto
- [ ] Schemas and changesets
- [ ] Migrations
- [ ] Queries (composable)
- [ ] Associations
- [ ] Transactions
- [ ] Multi (atomic operations)

---

## Tier 3: Power Features (Weekly Use)

### Month 6: LiveView
- [ ] LiveView lifecycle
- [ ] Events and handlers
- [ ] LiveComponents
- [ ] Streams (efficient large lists)
- [ ] JS hooks
- [ ] Uploads
- [ ] PubSub integration

### Month 7: Real-time & Testing
- [ ] Phoenix Channels
- [ ] Presence (who's online)
- [ ] ExUnit basics
- [ ] Testing Phoenix
- [ ] Testing LiveView
- [ ] Mox (mocking)
- [ ] StreamData (property testing)

### Month 8: Production
- [ ] Releases with `mix release`
- [ ] Runtime configuration
- [ ] Clustering nodes
- [ ] Health checks
- [ ] Telemetry and metrics
- [ ] Logger configuration

---

## Tier 4: Advanced (Monthly Use)

### Month 9-10: Distributed Systems
- [ ] Distributed Erlang basics
- [ ] `:global` and `:pg` (process groups)
- [ ] Horde (distributed supervisor/registry)
- [ ] CRDT patterns
- [ ] Phoenix.PubSub across nodes
- [ ] Consistent hashing

### Month 10-11: Metaprogramming
- [ ] Quote and unquote
- [ ] Macros (writing DSLs)
- [ ] Compile-time code generation
- [ ] Using `use` and `__using__`
- [ ] AST manipulation
- [ ] Compile hooks

### Month 12: Exotic Features
- [ ] NIFs (Rust/C integration)
- [ ] Ports (external programs)
- [ ] ETS (in-memory storage)
- [ ] DETS (persistent ETS)
- [ ] Mnesia (distributed database)
- [ ] `:observer` and debugging tools
- [ ] Custom Mix tasks
- [ ] Umbrella projects

---

## Tier 5: Rare But Important (Know They Exist)

- [ ] Hot code upgrades (appups/relups)
- [ ] Custom Ecto types
- [ ] Custom Phoenix generators
- [ ] Writing OTP-compatible libraries
- [ ] Dialyzer and Gradual Typing
- [ ] ExDoc for documentation
- [ ] Nerves (embedded systems)
- [ ] Nx (numerical computing)
- [ ] Membrane (multimedia)

---

## Milestone Projects

After each phase, build something real:

1. **After Elixir Core**: CLI tool that processes files concurrently
2. **After OTP**: Chat room with fault-tolerant state
3. **After Phoenix**: REST API with auth
4. **After Ecto**: Multi-tenant SaaS backend
5. **After LiveView**: Real-time dashboard
6. **After Channels**: Multiplayer game
7. **After Production**: Deploy a clustered app
8. **After Advanced**: Distributed cache with automatic rebalancing
9. **After Metaprogramming**: Your own DSL/framework

---

## How to Use This Curriculum

1. Read the concept file
2. Type every example yourself (don't copy-paste)
3. Break things intentionally
4. Do the exercises
5. Build the milestone project
6. Move on only when comfortable

Each topic file contains:
- Explanation
- Examples
- Common pitfalls
- Exercises (easy → hard)
- Real-world patterns
