# Testing

**Elixir has excellent testing built-in.** ExUnit comes with the language.

## Learning Order

1. [ExUnit Basics](01-exunit.md)
2. [Testing Phoenix](02-phoenix.md)
3. [Testing LiveView](03-liveview.md)
4. [Mocking with Mox](04-mox.md)
5. [Property Testing](05-property-testing.md)
6. [Test Factories](06-factories.md)

## Basic Test

```elixir
defmodule MyApp.CalculatorTest do
  use ExUnit.Case, async: true

  describe "add/2" do
    test "adds two positive numbers" do
      assert Calculator.add(1, 2) == 3
    end

    test "handles negative numbers" do
      assert Calculator.add(-1, -2) == -3
    end

    test "returns zero when adding opposites" do
      assert Calculator.add(5, -5) == 0
    end
  end
end
```

## Running Tests

```bash
# Run all tests
mix test

# Run specific file
mix test test/my_app/calculator_test.exs

# Run specific line
mix test test/my_app/calculator_test.exs:15

# Run with seed (reproducibility)
mix test --seed 12345

# Run failed tests only
mix test --failed

# Run with coverage
mix test --cover

# Verbose output
mix test --trace
```

## Assertions

```elixir
assert value                    # Truthy
refute value                    # Falsy
assert a == b                   # Equality
assert a =~ ~r/pattern/         # Regex match
assert_raise RuntimeError, fn -> ... end
assert_receive {:msg, value}    # Process mailbox
refute_receive :msg, 100        # With timeout
assert_in_delta 1.0, 1.001, 0.01
```

## Setup & Fixtures

```elixir
defmodule MyTest do
  use ExUnit.Case

  # Runs before each test
  setup do
    user = create_user()
    {:ok, user: user}  # Passed to test as context
  end

  # Named setup
  setup :create_user

  defp create_user(_context) do
    {:ok, user: %User{name: "Alice"}}
  end

  # Setup for describe block only
  describe "with admin" do
    setup do
      {:ok, user: %User{admin: true}}
    end

    test "can delete", %{user: user} do
      assert User.can_delete?(user)
    end
  end
end
```

## Async Tests

```elixir
# Safe for parallel execution
use ExUnit.Case, async: true

# Tests with shared state (database) - NOT async
use ExUnit.Case, async: false
```

## Testing Phoenix

### Controller Tests

```elixir
defmodule MyAppWeb.UserControllerTest do
  use MyAppWeb.ConnCase

  describe "index/2" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/users")
      assert html_response(conn, 200) =~ "Users"
    end
  end

  describe "create/2" do
    test "creates user with valid data", %{conn: conn} do
      conn = post(conn, ~p"/users", user: %{name: "Alice"})
      assert redirected_to(conn) =~ "/users/"
    end

    test "shows errors with invalid data", %{conn: conn} do
      conn = post(conn, ~p"/users", user: %{name: ""})
      assert html_response(conn, 200) =~ "can&#39;t be blank"
    end
  end
end
```

### LiveView Tests

```elixir
defmodule MyAppWeb.CounterLiveTest do
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest

  test "increments counter", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/counter")
    assert html =~ "Count: 0"

    html = view |> element("button", "+") |> render_click()
    assert html =~ "Count: 1"
  end

  test "validates form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/users/new")

    view
    |> form("#user-form", user: %{email: "invalid"})
    |> render_change()

    assert has_element?(view, ".error", "is invalid")
  end
end
```

## Mocking with Mox

```elixir
# Define behavior
defmodule MyApp.HttpClient do
  @callback get(String.t()) :: {:ok, map()} | {:error, term()}
end

# Define mock in test_helper.exs
Mox.defmock(MyApp.MockHttpClient, for: MyApp.HttpClient)

# Use in tests
defmodule MyTest do
  use ExUnit.Case
  import Mox

  setup :verify_on_exit!

  test "fetches data" do
    expect(MyApp.MockHttpClient, :get, fn url ->
      assert url == "http://api.example.com"
      {:ok, %{data: "test"}}
    end)

    assert {:ok, _} = MyService.fetch()
  end
end
```

## Database Tests

```elixir
defmodule MyApp.AccountsTest do
  use MyApp.DataCase  # Wraps each test in transaction

  alias MyApp.Accounts

  describe "create_user/1" do
    test "with valid data creates user" do
      assert {:ok, user} = Accounts.create_user(%{
        name: "Alice",
        email: "alice@example.com"
      })
      assert user.name == "Alice"
    end

    test "with invalid data returns changeset" do
      assert {:error, changeset} = Accounts.create_user(%{})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end
  end
end
```

---

## Exercises

### Exercise 1: Property Testing
```elixir
# Use StreamData to test:
# - reverse(reverse(list)) == list
# - sort is idempotent
# - encode/decode roundtrip

use ExUnitProperties

property "reversing twice gives original" do
  check all list <- list_of(integer()) do
    assert Enum.reverse(Enum.reverse(list)) == list
  end
end
```

### Exercise 2: Test Coverage
```elixir
# Set up coveralls or excoveralls
# Achieve 90%+ coverage for a module
# Identify which branches aren't covered
```

### Exercise 3: Integration Test
```elixir
# Write an end-to-end test that:
# - Creates a user via LiveView form
# - Verifies email sent (using Swoosh test adapter)
# - Confirms email
# - Logs in
# - Creates a post
```

---

## Best Practices

1. **Test behavior, not implementation**
2. **One assertion per test** (when practical)
3. **Use `describe` blocks** to group related tests
4. **Fast tests** - mock external services
5. **Meaningful names** - describe what, not how
6. **Setup at the right level** - not everything in module setup
