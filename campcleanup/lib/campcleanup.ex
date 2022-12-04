defmodule CampCleanup do
  @moduledoc """
  Documentation for `Campcleanup`.
  """

  def part1() do
    "input.txt"
    |> input()
    |> Enum.filter(&fully_contained/1)
    |> Enum.count()
  end

  def part2() do
    "input.txt"
    |> input()
    |> Enum.filter(&overlap/1)
    |> Enum.count()
  end

  def overlap({{s1, _e1}, {s2, e2}}) when s1 >= s2 and s1 <= e2, do: true
  def overlap({{s1, e1}, {s2, _e2}}) when s2 >= s1 and s2 <= e1, do: true
  def overlap({{_s1, _e1}, {_s2, _e2}}), do: false

  def fully_contained({{s1, e1}, {s2, e2}}) when s1 >= s2 and e1 <= e2, do: true
  def fully_contained({{s1, e1}, {s2, e2}}) when s2 >= s1 and e2 <= e1, do: true
  def fully_contained({{_s1, _e1}, {_s2, _e2}}), do: false

  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn l ->
      [p1, p2] =
        l
        |> String.split(",")
        |> Enum.map(fn a ->
          [s, e] =
            a
            |> String.split("-")
            |> Enum.map(fn e ->
              {n, _} = Integer.parse(e)
              n
            end)

          {s, e}
        end)

      {p1, p2}
    end)
  end
end
