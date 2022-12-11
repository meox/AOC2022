defmodule Monkey do
  @moduledoc """
  Documentation for `Monkey`.
  """

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    script =
      filename
      |> input()

    state = create_state(script)

    round(20, script, state, fn x -> :erlang.trunc(x / 3) end)
    |> monkey_business()
  end

  def create_state(script) do
    script
    |> Enum.reduce(
      %{},
      fn %{monkey: id, items: items}, state ->
        Map.put(state, id, {items, 0})
      end
    )
  end

  def round(0, _, state, _normalize), do: state

  def round(n, script, state, normalize) do
    new_state =
      script
      |> Enum.reduce(
        state,
        fn monkey, acc ->
          round(monkey, acc, normalize)
        end
      )

    round(n - 1, script, new_state, normalize)
  end

  def round(
        %{monkey: id, op: op, test: test, dest_true: dtrue, dest_false: dfalse},
        %{} = state,
        normalize
      ) do
    {items, inspected} = Map.get(state, id)

    new_state =
      items
      |> Enum.reduce(
        state,
        fn item, acc ->
          new = normalize.(apply_op(item, op))

          case rem(new, test) == 0 do
            true ->
              add_items(dtrue, new, acc)

            false ->
              add_items(dfalse, new, acc)
          end
        end
      )

    Map.put(new_state, id, {[], inspected + length(items)})
  end

  def add_items(dest_id, new, state) do
    Map.update(state, dest_id, {[new], 0}, fn {is, i} -> {is ++ [new], i} end)
  end

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    script =
      filename
      |> input()

    state = create_state(script)
    norm = fn x -> rem(x, max_value(script)) end

    round(10_000, script, state, norm)
    |> monkey_business()
  end

  def monkey_business(state) do
    state
    |> Map.values()
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end

  def apply_op(old, {'*', :old, :old}), do: old * old
  def apply_op(old, {'+', :old, :old}), do: old + old
  def apply_op(old, {'*', :old, n}), do: old * n
  def apply_op(old, {'+', :old, n}), do: old + n

  def max_value(script) do
    script
    |> Enum.map(fn %{test: m} -> m end)
    |> Enum.product()
  end

  @doc """
  input function
  """
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n\n")
    |> Enum.map(fn m ->
      [
        "Monkey " <> mid,
        "  Starting items: " <> items,
        "  Operation: new = " <> operation,
        "  Test: divisible by " <> test,
        "    If true: throw to monkey " <> m_true_dest,
        "    If false: throw to monkey " <> m_false_dest
      ] = String.split(m, "\n")

      %{
        monkey: mid |> String.trim(":") |> as_number(),
        items: items |> String.split(", ") |> as_numbers(),
        op: parse_op(operation),
        test: as_number(test),
        dest_true: as_number(m_true_dest),
        dest_false: as_number(m_false_dest)
      }
    end)
  end

  def parse_op("old * old"), do: {'*', :old, :old}
  def parse_op("old + old"), do: {'+', :old, :old}
  def parse_op("old * " <> ns), do: {'*', :old, as_number(ns)}
  def parse_op("old + " <> ns), do: {'+', :old, as_number(ns)}

  defp as_numbers(xs) when is_list(xs) do
    Enum.map(xs, &as_number/1)
  end

  defp as_number(s) do
    {n, ""} = Integer.parse(s)
    n
  end
end
