# Reference Solutions - Pattern Matching
# Try solving yourself first!

defmodule Solutions.Exercise1 do
  def extract_2d({x, y}), do: {x, y}

  def extract_3d({x, y, z}), do: {x, y, z}

  def extract_from_response({:ok, %{x: x, y: y}}), do: {x, y}
end

defmodule Solutions.Exercise2 do
  def classify([]), do: :empty
  def classify([_]), do: :single
  def classify([_, _]), do: :pair
  def classify([_, _, _]), do: :triple
  def classify([_ | _]), do: :many
end

defmodule Solutions.Exercise3 do
  def fizzbuzz(n) do
    case {rem(n, 3), rem(n, 5)} do
      {0, 0} -> "FizzBuzz"
      {0, _} -> "Fizz"
      {_, 0} -> "Buzz"
      _ -> Integer.to_string(n)
    end
  end

  # Alternative: function heads
  def fizzbuzz_v2(n), do: do_fizzbuzz(rem(n, 3), rem(n, 5), n)
  defp do_fizzbuzz(0, 0, _), do: "FizzBuzz"
  defp do_fizzbuzz(0, _, _), do: "Fizz"
  defp do_fizzbuzz(_, 0, _), do: "Buzz"
  defp do_fizzbuzz(_, _, n), do: Integer.to_string(n)
end

defmodule Solutions.Exercise4 do
  def sum([]), do: 0
  def sum([head | tail]) when is_list(head), do: sum(head) + sum(tail)
  def sum([head | tail]) when is_integer(head), do: head + sum(tail)

  # Alternative: using Enum
  def sum_v2(list) do
    list
    |> List.flatten()
    |> Enum.sum()
  end
end

defmodule Solutions.Exercise5 do
  def parse(""), do: {:error, :empty}

  def parse(string) do
    case String.split(string, "=", parts: 2) do
      [key, value] -> {:ok, {key, value}}
      [_] -> {:error, :invalid_format}
    end
  end
end

defmodule Solutions.Exercise6 do
  def parse(<<1, length::16-big, payload::binary-size(length), _rest::binary>>) do
    {:ok, %{type: :text, payload: payload}}
  end

  def parse(<<2, length::16-big, payload::binary-size(length), _rest::binary>>) do
    {:ok, %{type: :binary, payload: payload}}
  end

  def parse(<<3, length::16-big, payload::binary-size(length), _rest::binary>>) do
    {:ok, %{type: :ping, payload: payload}}
  end

  def parse(_), do: {:error, :invalid_format}

  # Alternative: more DRY
  def parse_v2(<<type, length::16-big, payload::binary-size(length), _::binary>>) do
    case type do
      1 -> {:ok, %{type: :text, payload: payload}}
      2 -> {:ok, %{type: :binary, payload: payload}}
      3 -> {:ok, %{type: :ping, payload: payload}}
      _ -> {:error, :unknown_type}
    end
  end
end
