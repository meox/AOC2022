defmodule Regolith do
  @moduledoc """
  Documentation for `Regolith`.
  """

  @sand {500, 0}

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    input = filename |> input() |> as_map()

    input
    |> tetris(@sand, max_y(input) + 1, :no_wall)
    |> Map.values()
    |> Enum.filter(fn
      :o -> true
      _ -> false
    end)
    |> Enum.count()
  end

  def tetris(m, {_x, y}, max_y, _vwall) when y > max_y do
    m
  end

  def tetris(m, p, max_y, vwall) do
    with nil <- Map.get(m, p, nil),
         {true, _} <- {blocked(m, d(p), max_y, vwall), d(p)},
         {true, _} <- {blocked(m, dl(p), max_y, vwall), dl(p)},
         {true, _} <- {blocked(m, dr(p), max_y, vwall), dr(p)} do
      tetris(Map.put(m, p, :o), @sand, max_y, vwall)
    else
      {false, p} -> tetris(m, p, max_y, vwall)
      :o -> m
      :r -> m
    end
  end

  def d({x, y}), do: {x, y + 1}
  def dl({x, y}), do: {x - 1, y + 1}
  def dr({x, y}), do: {x + 1, y + 1}

  def blocked(_m, {_x, max_y}, max_y, :wall), do: true
  def blocked(_m, {_x, max_y}, max_y, :no_wall), do: false

  def blocked(m, pos, _max_y, _) do
    case Map.get(m, pos, nil) do
      nil -> false
      _ -> true
    end
  end

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    input = filename |> input() |> as_map()

    input
    |> tetris(@sand, 2 + max_y(input), :wall)
    |> Map.values()
    |> Enum.filter(fn
      :o -> true
      _ -> false
    end)
    |> Enum.count()
  end

  def as_map(input) do
    input
    |> Enum.reduce(
      %{},
      fn path, acc ->
        pairs = Enum.zip(path, Enum.drop(path, 1))

        pairs
        |> Enum.reduce(
          acc,
          fn
            {{x1, y1}, {x2, y2}}, acc ->
              ps = for x <- x1..x2, y <- y1..y2, do: {x, y}

              ps
              |> Enum.reduce(acc, fn p, acc -> Map.put(acc, p, :r) end)
          end
        )
      end
    )
  end

  def max_y(input) do
    input
    |> Map.keys()
    |> Enum.reduce(
      0,
      fn
        {_, y}, my when y > my -> y
        _, my -> my
      end
    )
  end

  @doc """
  input function
  """
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ")
      |> Enum.map(fn pos ->
        [x, y] =
          pos
          |> String.split(",")
          |> as_numbers()

        {x, y}
      end)
    end)
  end

  defp as_numbers(xs) when is_list(xs) do
    Enum.map(xs, &as_number/1)
  end

  defp as_number(s) do
    {n, ""} = Integer.parse(s)
    n
  end
end
