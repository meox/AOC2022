defmodule Rucksack do
  @moduledoc """
  Documentation for `Rucksack`.
  """

  def part1() do
    items = input("input.txt")

    items
    |> Enum.map(fn {as, bs} -> diff(as, bs) end)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  def part2() do
    items = input("input.txt")

    items
    |> Enum.map(fn {x, y} -> MapSet.new(x ++ y) end)
    |> Enum.chunk_every(3)
    |> Enum.map(fn [g1, g2, g3] ->
      g1
      |> MapSet.intersection(g2)
      |> MapSet.intersection(g3)
      |> Enum.to_list()
      |> priority()
    end)
    |> Enum.sum()
  end

  def priority([x]) when x >= ?a and x <= ?z, do: x - ?a + 1
  def priority([x]) when x >= ?A and x <= ?Z, do: x - ?A + 27
  def priority(_), do: 0

  def diff(as, bs) do
    ma = MapSet.new(as)
    mb = MapSet.new(bs)

    MapSet.intersection(ma, mb)
    |> Enum.to_list()
  end

  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn s ->
      l = :erlang.trunc(String.length(s) / 2)
      {a, b} = String.split_at(s, l)
      {String.to_charlist(a), String.to_charlist(b)}
    end)
  end

end
