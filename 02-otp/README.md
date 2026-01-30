# OTP - Open Telecom Platform

**This is where Elixir's superpowers come from.**

OTP is a set of battle-tested behaviors for building concurrent, fault-tolerant systems. It's been refined for 30+ years in telecom (where downtime = lawsuits).

## The Key Insight

Instead of defensive programming:
```
try to prevent all errors
catch all exceptions
hope nothing crashes
```

OTP embraces:
```
let it crash
isolate failures to small processes
supervisors restart failed processes
system stays up
```

## Learning Order

1. [Processes](01-processes.md) - The foundation
2. [GenServer](02-genserver.md) - The workhorse behavior
3. [Supervisor](03-supervisor.md) - Fault tolerance
4. [Application](04-application.md) - Your app's entry point
5. [Registry](05-registry.md) - Process naming
6. [DynamicSupervisor](06-dynamic-supervisor.md) - Runtime process spawning
7. [Task](07-task.md) - Async operations
8. [Agent](08-agent.md) - Simple state
9. [GenStage](09-genstage.md) - Backpressure and flow
10. [ETS](10-ets.md) - In-memory storage

## Supervision Tree

Every OTP application is organized as a tree:

```
Application
    └── Supervisor
            ├── GenServer (business logic)
            ├── GenServer (cache)
            └── Supervisor
                    ├── GenServer (worker 1)
                    ├── GenServer (worker 2)
                    └── GenServer (worker 3)
```

When a process crashes, its supervisor restarts it. Siblings are unaffected.

## Mental Model

Think of processes as:
- **Independent workers** - each with their own state
- **Communicating via messages** - no shared memory
- **Supervised** - someone watching, ready to restart
- **Cheap** - spawn millions of them

```elixir
# Each user connection = 1 process
# Each game room = 1 process
# Each background job = 1 process
# Each cache partition = 1 process
```
