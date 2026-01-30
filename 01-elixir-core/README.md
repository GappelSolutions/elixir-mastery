# Elixir Core

The foundation. Everything else builds on this.

## Learning Order

1. [Pattern Matching](01-pattern-matching.md) - The single most important concept
2. [Data Types](02-data-types.md) - Tuples, lists, maps, structs
3. [Functions](03-functions.md) - Anonymous and named
4. [Modules](04-modules.md) - Code organization
5. [Control Flow](05-control-flow.md) - case, cond, with
6. [Recursion](06-recursion.md) - Loops don't exist
7. [Comprehensions](07-comprehensions.md) - Powerful iteration
8. [Strings & Binaries](08-strings.md) - Binary data handling
9. [Protocols](09-protocols.md) - Polymorphism
10. [Behaviors](10-behaviors.md) - Contracts

## Key Insight

Elixir is immutable. When you "update" data, you create new data. This sounds inefficient but:
- Structural sharing makes it cheap
- No locks needed for concurrency
- No defensive copying
- Time-travel debugging becomes possible

```elixir
# This doesn't modify the original
list = [1, 2, 3]
new_list = [0 | list]  # [0, 1, 2, 3]
# list is still [1, 2, 3]
```

## Setup for Exercises

```bash
# Create a practice project
mix new practice
cd practice

# Run interactive shell with your code loaded
iex -S mix

# Run tests
mix test
```
