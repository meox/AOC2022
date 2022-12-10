defmodule RayTube do
  @moduledoc """
  Documentation for `RayTube`.
  """

  def part1() do
    "input.txt"
    |> input()
    |> cycle()
    |> power(20..220//40)
    |> Enum.sum()
  end

  def part2() do
    "input.txt"
    |> input()
    |> cycle()
    |> Enum.chunk_every(40)
    |> Enum.map(&draw/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def draw(crt_line) do
    {_, line} =
    crt_line
    |> Enum.reduce(
      {0, []},
      fn
        x, {p, acc} when abs(p - x) <= 1 ->
          {p + 1, ["#" | acc]}
        _x, {p, acc} ->
          {p + 1, ["." | acc]}
      end
    )

    line
    |> Enum.reverse()
    |> Enum.join("")
  end

  def cycle(input) do
    input
    |> Enum.reduce(
      {1, []},
      fn
        :noop, {x, cs} ->
          {x, [x | cs]}

        {:addx, v}, {x, cs} ->
          nx = x + v
          {nx, [x, x | cs]}
      end
    )
    |> then(fn {_, rs} -> Enum.reverse(rs) end)
  end

  def power(xs, sr) do
    sr
    |> Enum.map(fn s -> s * Enum.at(xs, s - 1) end)
  end

  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn
      "noop" ->
        :noop

      "addx " <> v ->
        {n, ""} = Integer.parse(v)
        {:addx, n}
    end)
  end
end
