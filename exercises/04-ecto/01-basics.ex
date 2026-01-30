# Ecto Exercises
# These exercises are meant to be done in a Phoenix project with Ecto
# Create: mix phx.new my_app
# Then implement these schemas and queries

# =============================================================================
# Exercise 1: Blog Schema Design
# =============================================================================
# Create schemas for a blog:
# - User (name, email, bio)
# - Post (title, body, published_at, user_id)
# - Comment (body, user_id, post_id)
# - Tag (name) with many-to-many to Post

defmodule Exercise1 do
  # Define schemas here or in your Phoenix project

  defmodule User do
    # use Ecto.Schema
    # import Ecto.Changeset

    # schema "users" do
    #   field :name, :string
    #   field :email, :string
    #   field :bio, :string
    #
    #   has_many :posts, Post
    #   has_many :comments, Comment
    #
    #   timestamps()
    # end

    # def changeset(user, attrs) do
    #   user
    #   |> cast(attrs, [:name, :email, :bio])
    #   |> validate_required([:name, :email])
    #   |> validate_format(:email, ~r/@/)
    #   |> unique_constraint(:email)
    # end
  end

  defmodule Post do
    # schema "posts" do
    #   field :title, :string
    #   field :body, :string
    #   field :published_at, :utc_datetime
    #
    #   belongs_to :user, User
    #   has_many :comments, Comment
    #   many_to_many :tags, Tag, join_through: "posts_tags"
    #
    #   timestamps()
    # end
  end

  defmodule Comment do
    # TODO: Define schema
  end

  defmodule Tag do
    # TODO: Define schema with many_to_many
  end
end

# =============================================================================
# Exercise 2: Complex Queries
# =============================================================================
# Write these queries (implement in your Phoenix project):

defmodule Exercise2 do
  # import Ecto.Query

  # Find all users who have at least 5 published posts
  def prolific_authors do
    # from u in User,
    #   join: p in assoc(u, :posts),
    #   where: not is_nil(p.published_at),
    #   group_by: u.id,
    #   having: count(p.id) >= 5,
    #   select: u
    :todo
  end

  # Find posts with their comment count, ordered by most comments
  def posts_by_popularity do
    # from p in Post,
    #   left_join: c in assoc(p, :comments),
    #   group_by: p.id,
    #   order_by: [desc: count(c.id)],
    #   select: %{post: p, comment_count: count(c.id)}
    :todo
  end

  # Find users who joined in the last month with their post count
  def recent_users_with_posts do
    :todo
  end

  # Find all tags with their post counts, only for published posts
  def tag_popularity do
    :todo
  end

  # Search posts by title or body (case insensitive)
  def search_posts(query) do
    # Hint: use ilike
    _ = query
    :todo
  end
end

# =============================================================================
# Exercise 3: Changeset Pipeline
# =============================================================================
# Create a User changeset that:
# - Hashes password before insert
# - Generates confirmation token
# - Normalizes email (lowercase, trim)
# - Validates password complexity

defmodule Exercise3 do
  defmodule User do
    # defstruct [:email, :password, :password_hash, :confirmation_token]

    def registration_changeset(user, attrs) do
      # user
      # |> cast(attrs, [:email, :password])
      # |> validate_required([:email, :password])
      # |> normalize_email()
      # |> validate_password_complexity()
      # |> hash_password()
      # |> generate_confirmation_token()
      _ = {user, attrs}
      :todo
    end

    # defp normalize_email(changeset) do
    #   update_change(changeset, :email, fn email ->
    #     email |> String.trim() |> String.downcase()
    #   end)
    # end

    # defp validate_password_complexity(changeset) do
    #   validate_change(changeset, :password, fn :password, password ->
    #     cond do
    #       String.length(password) < 8 -> [password: "must be at least 8 characters"]
    #       not String.match?(password, ~r/[A-Z]/) -> [password: "must contain uppercase"]
    #       not String.match?(password, ~r/[0-9]/) -> [password: "must contain number"]
    #       true -> []
    #     end
    #   end)
    # end

    # defp hash_password(changeset) do
    #   if password = get_change(changeset, :password) do
    #     put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    #   else
    #     changeset
    #   end
    # end

    # defp generate_confirmation_token(changeset) do
    #   put_change(changeset, :confirmation_token, :crypto.strong_rand_bytes(32) |> Base.encode64())
    # end
  end
end

# =============================================================================
# Exercise 4: Multi Transaction
# =============================================================================
# Implement user registration that atomically:
# - Creates user
# - Creates default profile
# - Creates welcome notification
# - All or nothing

defmodule Exercise4 do
  # alias Ecto.Multi

  def register_user(attrs) do
    # Multi.new()
    # |> Multi.insert(:user, User.changeset(%User{}, attrs))
    # |> Multi.insert(:profile, fn %{user: user} ->
    #   Profile.changeset(%Profile{user_id: user.id}, %{bio: "New user"})
    # end)
    # |> Multi.insert(:notification, fn %{user: user} ->
    #   Notification.changeset(%Notification{}, %{
    #     user_id: user.id,
    #     type: :welcome,
    #     message: "Welcome to our platform!"
    #   })
    # end)
    # |> Repo.transaction()
    _ = attrs
    :todo
  end
end

# =============================================================================
# Exercise 5: Pagination
# =============================================================================
# Implement cursor-based pagination

defmodule Exercise5 do
  def paginate(query, opts \\ []) do
    # opts: cursor (last seen id), limit
    # Return %{entries: [...], next_cursor: id | nil}
    _ = {query, opts}
    :todo
  end
end

IO.puts """
Ecto exercises are meant to be implemented in a Phoenix project.

1. Create a new project:
   mix phx.new ecto_exercises
   cd ecto_exercises

2. Generate schemas:
   mix phx.gen.schema Accounts.User users name:string email:string bio:string
   mix phx.gen.schema Blog.Post posts title:string body:text published_at:utc_datetime user_id:references:users
   mix phx.gen.schema Blog.Comment comments body:text user_id:references:users post_id:references:posts
   mix phx.gen.schema Blog.Tag tags name:string

3. Create posts_tags join table migration

4. Update schemas with associations

5. Implement the queries in a context module

6. Test in iex -S mix:
   MyApp.Blog.prolific_authors() |> MyApp.Repo.all()
"""
