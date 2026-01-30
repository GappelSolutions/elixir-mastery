# Exercises

Hands-on practice for each section. Structure:

```
exercises/
  01-elixir-core/
    01-pattern-matching.ex    # Your solutions
    02-data-types.ex
    ...
  solutions/                   # Reference solutions (don't peek!)
    01-pattern-matching.ex
    ...
  projects/                    # Milestone projects
    01-cli-tool/
    02-chat-server/
    ...
```

## Workflow

1. Read the docs in the main section (e.g., `01-elixir-core/01-pattern-matching.md`)
2. Create your solution file in exercises (e.g., `exercises/01-elixir-core/01-pattern-matching.ex`)
3. Run with `elixir exercises/01-elixir-core/01-pattern-matching.ex` or in `iex`
4. Use `/elixir-review exercises/01-elixir-core/01-pattern-matching.ex` for feedback
5. Compare to solution only after attempting

## Progress Tracking

Use git to track your progress:

```bash
# After completing an exercise
git add exercises/01-elixir-core/01-pattern-matching.ex
git commit -m "complete: pattern matching exercises"
```

## Testing Your Solutions

Each exercise file should be runnable:

```elixir
# exercises/01-elixir-core/01-pattern-matching.ex

defmodule PatternMatching.Exercise1 do
  # Your solution here
end

# Test it
IO.inspect PatternMatching.Exercise1.some_function([1, 2, 3])
```

Or use ExUnit:

```elixir
ExUnit.start()

defmodule PatternMatchingTest do
  use ExUnit.Case

  test "exercise 1" do
    assert PatternMatching.Exercise1.classify([]) == :empty
    assert PatternMatching.Exercise1.classify([1]) == :single
  end
end
```

## Exercise Difficulty

Each section's exercises are ordered by difficulty:
- **1-2**: Warm-up, direct application of concepts
- **3-4**: Intermediate, combining multiple concepts
- **5+**: Challenging, requires deeper understanding

## Getting Feedback

Use the Claude command for deep code review:

```
/elixir-review exercises/01-elixir-core/01-pattern-matching.ex
```

This gives you:
- Correctness check
- Idiomatic Elixir feedback
- Performance considerations
- Best practices
- Suggestions for improvement
