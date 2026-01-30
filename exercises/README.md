# Milestone Projects

Build real things. Don't just read - code.

## Month 1-2: CLI Tool

**Build a concurrent file processor.**

Requirements:
- Accept directory path as argument
- Find all files matching a pattern
- Process each file in parallel
- Aggregate results
- Show progress

```bash
./processor --pattern "*.log" --dir /var/log --workers 4
```

Skills practiced:
- Pattern matching
- Recursion
- Task async/await
- File IO
- CLI argument parsing (OptionParser)

---

## Month 3: Chat Server

**Build a terminal chat room with fault tolerance.**

Requirements:
- Multiple clients connect via TCP
- Rooms with join/leave
- Private messages
- User list
- Survives client crashes
- Persists message history

Skills practiced:
- GenServer
- Supervisor trees
- Process registry
- TCP sockets (`:gen_tcp`)
- Binary protocols

---

## Month 4: REST API

**Build a blog API with authentication.**

Requirements:
- User registration/login (JWT)
- CRUD for posts
- Comments with nesting
- Tags (many-to-many)
- Pagination
- Rate limiting

Skills practiced:
- Phoenix controllers
- Ecto schemas & queries
- Changesets & validation
- Plugs (auth middleware)
- JSON serialization

---

## Month 5: Multi-tenant SaaS

**Add multi-tenancy to the blog.**

Requirements:
- Organizations with members
- Tenant isolation at database level
- Role-based permissions
- Subdomain routing
- Billing integration (mock)

Skills practiced:
- Complex Ecto queries
- Database constraints
- Context design
- Middleware patterns

---

## Month 6: Real-time Dashboard

**Build a LiveView monitoring dashboard.**

Requirements:
- Real-time metrics (CPU, memory, processes)
- Interactive charts (JS hooks)
- Alert configuration
- Historical data
- Multi-user with presence

Skills practiced:
- LiveView lifecycle
- Streams for performance
- JS interop
- PubSub
- Telemetry

---

## Month 7: Multiplayer Game

**Build a real-time multiplayer game.**

Ideas:
- Tic-tac-toe
- Chess
- Card game
- Trivia

Requirements:
- Matchmaking
- Game state sync
- Turn management
- Spectator mode
- Leaderboard

Skills practiced:
- Phoenix Channels
- Presence
- Game state machines
- Concurrency patterns

---

## Month 8: Production Deployment

**Deploy your app properly.**

Requirements:
- Docker container
- Kubernetes or Fly.io
- Clustering (multiple nodes)
- Database migrations
- Health checks
- Logging & metrics (Prometheus)
- CI/CD pipeline

Skills practiced:
- Releases (`mix release`)
- Runtime configuration
- Distributed Elixir
- Monitoring

---

## Month 9-10: Distributed Cache

**Build a distributed cache like Redis.**

Requirements:
- Key-value storage
- TTL support
- Pub/Sub
- Clustering (partition data across nodes)
- Replication for fault tolerance
- CLI client

Skills practiced:
- ETS
- Distributed Erlang
- Consistent hashing
- CAP tradeoffs
- Network protocols

---

## Month 11: Job Queue

**Build a background job processor.**

Requirements:
- Enqueue jobs with arguments
- Priority queues
- Scheduled jobs
- Retries with backoff
- Dead letter queue
- Web UI for monitoring
- Persistence

Skills practiced:
- GenStage/Flow
- Database-backed queues
- Supervision strategies
- Failure handling

---

## Month 12: Your Framework

**Build a minimal web framework or DSL.**

Ideas:
- Micro web framework (like Sinatra)
- GraphQL library
- State machine DSL
- Testing framework
- Form validation library

Requirements:
- Clean API
- Documentation
- Tests
- Published to Hex.pm

Skills practiced:
- Metaprogramming
- Library design
- Documentation (ExDoc)
- Publishing packages

---

## How to Approach Projects

1. **Start simple** - Get something working first
2. **Add complexity gradually** - Don't over-engineer upfront
3. **Test as you go** - Not just at the end
4. **Read source code** - See how Phoenix/Ecto do it
5. **Break things** - Kill processes, drop connections, corrupt data
6. **Refactor** - Your first design won't be your best

## Resources

- [Elixir Forum](https://elixirforum.com) - Best community
- [ElixirSchool](https://elixirschool.com) - Tutorials
- [HexDocs](https://hexdocs.pm) - Documentation
- [Elixir Radar](https://elixir-radar.com) - Newsletter
- [Thinking Elixir Podcast](https://thinkingelixir.com)
