defmodule Signal do
  @moduledoc """
  Documentation for `Signal`.
  """

  def part1() do
    "input.txt"
    |> input()
    |> find_start_marker(4)
  end

  def part2() do
    "input.txt"
    |> input()
    |> find_start_marker(14)
  end

  def find_start_marker(s, marker_len) when is_binary(s) do
    s
    |> String.to_charlist()
    |> find_start_marker(marker_len)
  end

  def find_start_marker(s, marker_len) do
    s
    |> Enum.reduce_while(
      {0, []},
      fn
        x, {n, acc} when length(acc) < marker_len - 1 ->
          {:cont, {n + 1, [x | acc]}}
        x, {n, acc} ->
          new_acc = [x | acc] |> Enum.take(marker_len)
          case is_start_marker(new_acc) do
            true ->
              {:halt, n + 1}
            false ->
              {:cont, {n + 1, new_acc}}
          end
      end
    )
  end

  def is_start_marker(ls) do
   length(Enum.uniq(ls)) == length(ls)
  end

  def input(filename) do
    filename
    |> File.read!()
    |> String.to_charlist()
  end
end
