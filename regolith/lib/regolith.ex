defmodule Regolith do
  @moduledoc """
  Documentation for `Regolith`.
  """

  @sand {500, 0}

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    input = filename |> input() |> as_map()

    max_y =
      input
      |> Map.keys()
      |> Enum.reduce(
        0,
        fn
          {_, y}, my when y > my -> y
          _, my -> my
        end
      )

    input
    |> tetris(@sand, max_y + 1)
    |> Map.values()
    |> Enum.filter(fn
      :o -> true
      _ -> false
    end)
    |> Enum.count()
  end

  def tetris(m, {_x, y}, max_y) when y > max_y do
    m
  end

  def tetris(m, {x, y} = p, max_y) do

    with nil <- Map.get(m, p, nil),
          {true, _} <- {blocked(m, d(p), max_y), d(p)},
          {true,_} <- {blocked(m, dl(p), max_y), dl(p)},
          {true,_} <- {blocked(m, dr(p), max_y), dr(p)}
          do
            tetris(Map.put(m, p, :o), @sand, max_y)
          else
            {false, p} -> tetris(m, p, max_y)
            :o -> m
          end

    case Map.get(m, {x, y}, nil) do
      :o ->
        m

      _ ->
        case blocked(m, {x, y + 1}, max_y) do
          true ->
            # try down left
            case blocked(m, {x - 1, y + 1}, max_y) do
              false ->
                tetris(m, {x - 1, y + 1}, max_y)

              true ->
                # try down right
                case blocked(m, {x + 1, y + 1}, max_y) do
                  true ->
                    # blocked
                    tetris(Map.put(m, {x, y}, :o), @sand, max_y)

                  false ->
                    tetris(m, {x + 1, y + 1}, max_y)
                end
            end

          false ->
            tetris(m, {x, y + 1}, max_y)
        end
    end
  end

  def d({x, y}), do: {x, y + 1}
  def dl({x, y}), do: {x-1, y + 1}
  def dr({x, y}), do: {x+1, y + 1}


  def blocked(_m, {_x, max_y}, max_y) do
    true
  end

  def blocked(m, pos, _max_y) do
    case Map.get(m, pos, nil) do
      nil -> false
      _ -> true
    end
  end

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    input = filename |> input() |> as_map()

    max_y =
      input
      |> Map.keys()
      |> Enum.reduce(
        0,
        fn
          {_, y}, my when y > my -> y
          _, my -> my
        end
      )

    input
    |> tetris(@sand, 2 + max_y)
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
