defmodule Day1 do
  @moduledoc """
  Documentation for `Day1`.
  """

  def part1() do
    "input.txt"
    |> parse_input()
    |> Enum.map(fn cs -> Enum.sum(cs) end)
    |> Enum.max()
  end

  def part2() do
    "input.txt"
    |> parse_input()
    |> Enum.map(fn cs -> Enum.sum(cs) end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  def parse_input(filename) do
    filename
    |> File.read!()
    |> String.split("\n\n")
    |> Enum.map(fn ls ->
      ls
      |> String.split("\n")
      |> Enum.map(fn s ->
          {r, _} = Integer.parse(s)
          r
        end)
      end)
  end
end
