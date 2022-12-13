defmodule Distress do
  @moduledoc """
  Documentation for `Distress`.
  """

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    filename
    |> input()
    |> Enum.with_index(fn element, index -> {index + 1, element} end)
    |> Enum.map(fn {idx, {l, r}} -> {idx, right_order(l, r)} end)
    |> Enum.filter(fn {_, v} -> v end)
    |> Enum.map(fn {idx, _} -> idx end)
    |> Enum.sum()
  end

  def right_order(l, r) when is_number(l) and is_number(r) do
    case l do
      ^r -> :continue
      x -> x < r
    end
  end

  def right_order([], []) do
    :continue
  end

  def right_order([], rs) when is_list(rs) and length(rs) > 0 do
    true
  end

  def right_order(ls, []) when is_list(ls) and length(ls) > 0 do
    false
  end

  def right_order(l, rs) when is_integer(l) and is_list(rs) do
    right_order([l], rs)
  end

  def right_order(ls, r) when is_integer(r) and is_list(ls) do
    right_order(ls, [r])
  end

  def right_order([l | ls], [r | rs]) do
    case right_order(l, r) do
      true ->
        true

      :continue ->
        right_order(ls, rs)

      _ ->
        false
    end
  end

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    filename
    |> input()
    |> Enum.flat_map(fn {l, r} -> [l, r] end)
    |> then(fn xs -> xs ++ [[[2]], [[6]]] end)
    |> Enum.sort(fn p1, p2 -> right_order(p1, p2) end)
    |> Enum.with_index(fn element, index -> {index + 1, element} end)
    |> Enum.filter(fn
      {_, [[2]]} -> true
      {_, [[6]]} -> true
      _ -> false
    end)
    |> Enum.map(fn {idx, _} -> idx end)
    |> Enum.product()
  end

  @doc """
  input function
  """
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n\n")
    |> Enum.map(fn pairs ->
      [l, r] =
        String.split(pairs, "\n")
        |> Enum.map(&parse_list/1)

      {l, r}
    end)
  end

  def parse_list(line) do
    {_, _, [acc], _} =
      line
      |> String.to_charlist()
      |> Enum.reduce(
        {0, %{}, [], []},
        fn
          ?[, {level, stack, acc, nstr} ->
            {level + 1, Map.put(stack, level, acc), [], nstr}

          ?], {level, stack, acc, nstr} ->
            new_level = level - 1

            new_acc =
              [as_number(nstr) | acc]
              |> Enum.reject(fn
                nil -> true
                _ -> false
              end)
              |> Enum.reverse()

            new_stack = Map.delete(stack, level)
            curr = Map.get(stack, new_level)
            {new_level, new_stack, [new_acc | curr], []}

          ?,, {level, stack, acc, []} ->
            {level, stack, acc, []}

          ?,, {level, stack, acc, nstr} ->
            {level, stack, [as_number(nstr) | acc], []}

          d, {level, stack, acc, nstr} ->
            {level, stack, acc, nstr ++ [d]}
        end
      )

    acc
  end

  defp as_number([]), do: nil

  defp as_number(s) do
    :erlang.list_to_integer(s)
  end
end
