# LiveView Exercises
# These exercises are meant to be done in a Phoenix project
# Create a new project: mix phx.new my_app --live
# Then implement these modules

# =============================================================================
# Exercise 1: Counter with Reset
# =============================================================================
# Build a counter LiveView with:
# - Increment/decrement buttons
# - Reset button
# - Display current count
# - Show "High score" (max value reached this session)

defmodule Exercise1.CounterLive do
  # use MyAppWeb, :live_view

  # Uncomment and implement in your Phoenix project:

  # def mount(_params, _session, socket) do
  #   {:ok, assign(socket, count: 0, high_score: 0)}
  # end

  # def handle_event("increment", _params, socket) do
  #   :todo
  # end

  # def handle_event("decrement", _params, socket) do
  #   :todo
  # end

  # def handle_event("reset", _params, socket) do
  #   :todo
  # end

  # def render(assigns) do
  #   ~H"""
  #   <div>
  #     <h1>Count: <%= @count %></h1>
  #     <p>High Score: <%= @high_score %></p>
  #     <button phx-click="decrement">-</button>
  #     <button phx-click="increment">+</button>
  #     <button phx-click="reset">Reset</button>
  #   </div>
  #   """
  # end
end

# =============================================================================
# Exercise 2: Live Search
# =============================================================================
# Implement live search:
# - Input field with debounce (300ms)
# - Show loading state while searching
# - Display results
# - Handle empty results

defmodule Exercise2.SearchLive do
  # def mount(_params, _session, socket) do
  #   {:ok, assign(socket, query: "", results: [], loading: false)}
  # end

  # def handle_event("search", %{"query" => query}, socket) do
  #   # Trigger async search
  #   :todo
  # end

  # def handle_info({:search_results, results}, socket) do
  #   :todo
  # end

  # def render(assigns) do
  #   ~H"""
  #   <div>
  #     <input
  #       type="text"
  #       phx-change="search"
  #       phx-debounce="300"
  #       value={@query}
  #       placeholder="Search..."
  #     />
  #
  #     <%= if @loading do %>
  #       <p>Loading...</p>
  #     <% end %>
  #
  #     <ul>
  #       <%= for result <- @results do %>
  #         <li><%= result %></li>
  #       <% end %>
  #     </ul>
  #   </div>
  #   """
  # end
end

# =============================================================================
# Exercise 3: Todo List with Streams
# =============================================================================
# Build a todo list using streams for efficiency:
# - Add new todos
# - Toggle complete
# - Delete todos
# - Filter (all/active/completed)

defmodule Exercise3.TodoLive do
  # def mount(_params, _session, socket) do
  #   todos = [
  #     %{id: 1, text: "Learn Elixir", completed: false},
  #     %{id: 2, text: "Build app", completed: false}
  #   ]
  #   {:ok, socket |> assign(filter: :all) |> stream(:todos, todos)}
  # end

  # def handle_event("add", %{"text" => text}, socket) do
  #   # Use stream_insert
  #   :todo
  # end

  # def handle_event("toggle", %{"id" => id}, socket) do
  #   # Use stream_insert to update
  #   :todo
  # end

  # def handle_event("delete", %{"id" => id}, socket) do
  #   # Use stream_delete
  #   :todo
  # end

  # def handle_event("filter", %{"filter" => filter}, socket) do
  #   :todo
  # end
end

# =============================================================================
# Exercise 4: Real-time Dashboard
# =============================================================================
# Build a dashboard that updates in real-time:
# - Subscribe to PubSub on mount
# - Display metrics (CPU, memory, etc.)
# - Auto-refresh every 5 seconds
# - Show sparkline of recent values

defmodule Exercise4.DashboardLive do
  # def mount(_params, _session, socket) do
  #   if connected?(socket) do
  #     # Subscribe to updates
  #     # Schedule periodic refresh
  #   end
  #   {:ok, assign(socket, metrics: %{}, history: [])}
  # end

  # def handle_info(:refresh, socket) do
  #   # Fetch new metrics
  #   # Update history
  #   # Schedule next refresh
  #   :todo
  # end

  # def handle_info({:metric_update, metric}, socket) do
  #   :todo
  # end
end

# =============================================================================
# Exercise 5: Form with Validation
# =============================================================================
# Build a user registration form:
# - Real-time validation on change
# - Show errors inline
# - Disable submit until valid
# - Show success message on submit

defmodule Exercise5.RegistrationLive do
  # def mount(_params, _session, socket) do
  #   changeset = User.changeset(%User{}, %{})
  #   {:ok, assign(socket, form: to_form(changeset), submitted: false)}
  # end

  # def handle_event("validate", %{"user" => params}, socket) do
  #   changeset =
  #     %User{}
  #     |> User.changeset(params)
  #     |> Map.put(:action, :validate)
  #
  #   {:noreply, assign(socket, form: to_form(changeset))}
  # end

  # def handle_event("submit", %{"user" => params}, socket) do
  #   :todo
  # end
end

# =============================================================================
# Mock modules for local testing
# =============================================================================

defmodule User do
  defstruct [:name, :email, :password]

  def changeset(user, attrs) do
    # Simplified changeset for demonstration
    %{
      data: user,
      changes: attrs,
      errors: validate(attrs),
      valid?: validate(attrs) == [],
      action: nil
    }
  end

  defp validate(attrs) do
    errors = []
    errors = if blank?(attrs["name"]), do: [{:name, "can't be blank"} | errors], else: errors
    errors = if blank?(attrs["email"]), do: [{:email, "can't be blank"} | errors], else: errors
    errors = if !String.contains?(attrs["email"] || "", "@"), do: [{:email, "must contain @"} | errors], else: errors
    errors
  end

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(_), do: false
end

IO.puts """
LiveView exercises are meant to be implemented in a Phoenix project.

1. Create a new project:
   mix phx.new live_exercises --live
   cd live_exercises

2. Copy these exercise modules to lib/live_exercises_web/live/

3. Add routes in router.ex:
   live "/counter", CounterLive
   live "/search", SearchLive
   live "/todos", TodoLive
   live "/dashboard", DashboardLive
   live "/register", RegistrationLive

4. Implement each module

5. Test at http://localhost:4000/counter etc.
"""
