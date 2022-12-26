defmodule PyroFlow do
  @moduledoc """
  Documentation for `PyroFlow`.
  """

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    max_rocks = 2022

    jet_seq = filename |> input()
    {max_h, _m, _} = tetris(jet_seq, 0, 0, %{}, max_rocks, 0)
    # debug(m, max_h)
    max_h
  end

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    max_rocks = 1_000_000_000_000

    jet_seq = filename |> input()

    freqs = find_period(jet_seq, 3000)
    vmax = Enum.max(freqs)

    {_, maxp} =
      freqs
      |> Enum.reduce(
        {0, []},
        fn
          ^vmax, {x, acc} -> {x + 1, [x | acc]}
          _, {x, acc} -> {x + 1, acc}
        end
      )

    maxp |> Enum.reverse() |> IO.inspect()

    freq = 348

    mul_factor = trunc(max_rocks / freq)

    {max_h1, _m, _} = tetris(jet_seq, 0, 0, %{}, freq, 0)
    {max_h2, _m, _} = tetris(jet_seq, 0, 0, %{}, 2 * freq, 0)
    grh = max_h2 - max_h1

    remanins = rem(max_rocks - freq, freq)
    {max_h3, _m, _} = tetris(jet_seq, 0, 0, %{}, remanins, 0)

    grh * mul_factor + max_h3
  end

  def find_period(jet_seq, n) do
    base = 1
    {_max_h1, _, prev_level} = tetris(jet_seq, 0, 0, %{}, base, 0)
    find_period(jet_seq, prev_level, base + 1, n, [prev_level])
  end

  def find_period(_jet_seq, _prev_level, _r, 0, ls) do
    ls |> Enum.reverse()
    # fs = ls |> Enum.reverse()
    # fs
    # |> Enum.drop(1)
    # |> Enum.zip(fs)
    # |> Enum.map(fn {a, b} -> a - b end)
  end

  def find_period(jet_seq, prev_level, r, n, ls) do
    {_max_h, _m, level} = tetris(jet_seq, 0, 0, %{}, r, 0)
    find_period(jet_seq, prev_level, r + 1, n - 1, [level | ls])
  end

  def debug(m, max_h) do
    (max_h - 1)..0
    |> Enum.map(fn y ->
      0..6
      |> Enum.map(fn x ->
        case Map.get(m, {x, y}, false) do
          false -> "."
          _ -> "#"
        end
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def tetris(_jet_seq, _shape, max_h, m, 0, level), do: {max_h, m, level}

  def tetris(jet_seq, shape, max_h, m, max_rocks, _level) do
    {jet_seq, new_m, _new_x, y} =
      (max_h + 3)..0
      |> Enum.reduce_while(
        {jet_seq, m, 2, 0},
        fn y, {jet_seq, m, x, _y_collision} ->
          [jd | _] = jet_seq
          new_jet_seq = shift(jet_seq)
          new_x = jet_move(shape, m, jd, x, y)

          case check_collision(shape, new_x, y - 1, m) do
            true ->
              new_m = Map.merge(m, shape_map(shape, new_x, y))
              {:halt, {new_jet_seq, new_m, new_x, y}}

            false ->
              {:cont, {new_jet_seq, m, new_x, y}}
          end
        end
      )

    new_max_h = max(max_h, y + height(shape))
    {new_m, level} = cap(new_m, new_max_h)

    tetris(jet_seq, rem(shape + 1, 5), new_max_h, new_m, max_rocks - 1, level)
  end

  def cap(m, max_h) do
    level =
      0..6
      |> Enum.map(fn x ->
        max_h..0
        |> Enum.reduce_while(
          max_h,
          fn y, _h ->
            case Map.get(m, {x, y}, false) do
              true -> {:halt, y}
              false -> {:cont, y}
            end
          end
        )
      end)
      |> Enum.min()

    new_m =
      m
      |> Map.keys()
      |> Enum.reduce(
        %{},
        fn
          {_x, y}, acc when y < level ->
            acc

          {x, y}, acc ->
            Map.put(acc, {x, y}, true)
        end
      )

    {new_m, max_h - level}
  end

  def shift([a | rs]), do: rs ++ [a]

  def jet_move(shape, m, :l, x, y) do
    shape
    |> shape_map(x - 1, y)
    |> Map.keys()
    |> Enum.any?(fn
      {x, _y} when x < 0 -> true
      {x, y} -> Map.get(m, {x, y}, false)
    end)
    |> then(fn
      true -> x
      _ -> x - 1
    end)
  end

  def jet_move(shape, m, :r, x, y) do
    shape
    |> shape_map(x + 1, y)
    |> Map.keys()
    |> Enum.any?(fn
      {x, _y} when x > 6 -> true
      {x, y} -> Map.get(m, {x, y}, false)
    end)
    |> then(fn
      true -> x
      _ -> x + 1
    end)
  end

  def height(0), do: 1
  def height(1), do: 3
  def height(2), do: 3
  def height(3), do: 4
  def height(4), do: 2

  def width(0), do: 4
  def width(1), do: 3
  def width(2), do: 3
  def width(3), do: 1
  def width(4), do: 2

  def shape_map(0, x, y) do
    %{
      {x, y} => true,
      {x + 1, y} => true,
      {x + 2, y} => true,
      {x + 3, y} => true
    }
  end

  def shape_map(1, x, y) do
    %{
      {x + 1, y} => true,
      {x + 0, y + 1} => true,
      {x + 1, y + 1} => true,
      {x + 2, y + 1} => true,
      {x + 1, y + 2} => true
    }
  end

  def shape_map(2, x, y) do
    %{
      {x, y} => true,
      {x + 1, y} => true,
      {x + 2, y} => true,
      {x + 2, y + 1} => true,
      {x + 2, y + 2} => true
    }
  end

  def shape_map(3, x, y) do
    %{
      {x, y} => true,
      {x, y + 1} => true,
      {x, y + 2} => true,
      {x, y + 3} => true
    }
  end

  def shape_map(4, x, y) do
    %{
      {x, y} => true,
      {x, y + 1} => true,
      {x + 1, y} => true,
      {x + 1, y + 1} => true
    }
  end

  def check_collision(_, _x, -1, _m), do: true

  def check_collision(shape, x, y, m) do
    shape
    |> shape_map(x, y)
    |> Map.keys()
    |> Enum.any?(&Map.get(m, &1, false))
  end

  @doc """
  input function
  """
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("", trim: true)
    |> Enum.map(fn
      "<" -> :l
      ">" -> :r
    end)
  end
end
