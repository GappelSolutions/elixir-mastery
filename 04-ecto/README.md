# Ecto

Database wrapper and query generator. Not an ORM - explicit and composable.

## Learning Order

1. [Schemas](01-schemas.md)
2. [Changesets](02-changesets.md)
3. [Queries](03-queries.md)
4. [Associations](04-associations.md)
5. [Migrations](05-migrations.md)
6. [Transactions](06-transactions.md)
7. [Multi](07-multi.md)

## Core Concepts

### Repo

Interface to the database.

```elixir
# Get all
Repo.all(User)

# Get by ID
Repo.get(User, 1)
Repo.get!(User, 1)  # Raises if not found

# Get by attribute
Repo.get_by(User, email: "alice@example.com")

# Insert
Repo.insert(%User{name: "Alice"})
Repo.insert!(user)

# Update
Repo.update(changeset)

# Delete
Repo.delete(user)
Repo.delete!(user)
```

### Schema

Maps database table to Elixir struct.

```elixir
defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :age, :integer
    field :admin, :boolean, default: false

    has_many :posts, MyApp.Blog.Post
    belongs_to :organization, MyApp.Accounts.Organization

    timestamps()  # inserted_at, updated_at
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :age, :admin])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> validate_number(:age, greater_than: 0)
    |> unique_constraint(:email)
  end
end
```

### Changeset

Validates and tracks changes.

```elixir
# Create changeset
changeset = User.changeset(%User{}, %{name: "Alice", email: "a@b.com"})

# Check validity
changeset.valid?  # true or false

# Get errors
changeset.errors  # [email: {"is invalid", [...]}]

# Apply changes (without saving)
Ecto.Changeset.apply_changes(changeset)

# Insert with changeset
Repo.insert(changeset)
```

### Query

Composable database queries.

```elixir
import Ecto.Query

# Basic query
from u in User, where: u.age > 18, select: u

# Query functions
User
|> where([u], u.active == true)
|> where([u], u.age >= 18)
|> order_by([u], desc: u.inserted_at)
|> limit(10)
|> Repo.all()

# Preload associations
User
|> preload(:posts)
|> Repo.all()

# Join
from u in User,
  join: p in assoc(u, :posts),
  where: p.published == true,
  select: {u.name, count(p.id)},
  group_by: u.name
```

## Migrations

```elixir
defmodule MyApp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :age, :integer
      add :organization_id, references(:organizations)

      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, [:organization_id])
  end
end
```

```bash
mix ecto.gen.migration create_users
mix ecto.migrate
mix ecto.rollback
```

## Transactions

```elixir
Repo.transaction(fn ->
  user = Repo.insert!(%User{name: "Alice"})
  Repo.insert!(%Post{title: "Hello", user_id: user.id})
  user
end)
# {:ok, user} or {:error, reason}
```

### Multi

Composable transactions.

```elixir
alias Ecto.Multi

Multi.new()
|> Multi.insert(:user, User.changeset(%User{}, user_params))
|> Multi.insert(:post, fn %{user: user} ->
  Post.changeset(%Post{user_id: user.id}, post_params)
end)
|> Multi.update(:user_stats, fn %{user: user} ->
  Stats.increment_changeset(user.stats)
end)
|> Repo.transaction()

# Returns:
# {:ok, %{user: user, post: post, user_stats: stats}}
# {:error, :user, changeset, %{}}  # Which step failed
```

---

## Quick Reference

### Changeset Validations

```elixir
cast(data, attrs, [:field1, :field2])
validate_required(changeset, [:field1])
validate_length(changeset, :name, min: 2, max: 100)
validate_format(changeset, :email, ~r/@/)
validate_inclusion(changeset, :role, ["admin", "user"])
validate_exclusion(changeset, :name, ["admin"])
validate_number(changeset, :age, greater_than: 0)
validate_confirmation(changeset, :password)
validate_acceptance(changeset, :terms)
unique_constraint(changeset, :email)
foreign_key_constraint(changeset, :organization_id)
check_constraint(changeset, :age, name: :age_must_be_positive)
```

### Query Examples

```elixir
# Select specific fields
from u in User, select: %{name: u.name, email: u.email}

# Aggregate
from p in Post, select: count(p.id)
from p in Post, select: avg(p.views)

# Subquery
popular_posts = from p in Post, where: p.views > 1000
from u in User,
  join: p in subquery(popular_posts),
  on: p.user_id == u.id

# Dynamic queries
dynamic = dynamic([u], u.active == true)
dynamic = if admin?, do: dynamic, else: dynamic([u], ^dynamic and u.role == "user")
from u in User, where: ^dynamic

# Fragment (raw SQL)
from u in User,
  where: fragment("lower(?)", u.email) == ^email
```

---

## Exercises

### Exercise 1: Blog Schema
```elixir
# Create schemas for:
# - User (name, email, bio)
# - Post (title, body, published_at)
# - Comment (body, user_id, post_id)
# - Tag (name), with many-to-many to Post
```

### Exercise 2: Complex Query
```elixir
# Find all users who:
# - Have at least 5 published posts
# - Joined in the last year
# - Return with their 3 most recent posts preloaded
```

### Exercise 3: Changeset Pipeline
```elixir
# Create a User changeset that:
# - Hashes password before insert
# - Generates confirmation token
# - Normalizes email (lowercase, trim)
# - Validates password complexity
```

### Exercise 4: Multi Transaction
```elixir
# Implement user registration that:
# - Creates user
# - Creates default profile
# - Sends welcome email (as part of transaction)
# - Rolls back everything if any step fails
```
