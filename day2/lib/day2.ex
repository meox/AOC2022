defmodule Day2 do
  @moduledoc """
  Documentation for `Day2`.
  """

  def part1() do
    input()
    |> Enum.map(fn {x, y} -> {conv(x), conv(y)} end)
    |> Enum.map(&play_round/1)
    |> Enum.sum()
  end

  def part2() do
    input()
    |> Enum.map(fn {x, y} ->
      other = conv(x)
      me = choose(other, policy(y))
      {other, me}
    end)
    |> Enum.map(&play_round/1)
    |> Enum.sum()
  end

  def choose(x, :draw), do: x
  def choose(:rock, :win), do: :paper
  def choose(:paper, :win), do: :scissor
  def choose(:scissor, :win), do: :rock
  def choose(:rock, :loose), do: :scissor
  def choose(:paper, :loose), do: :rock
  def choose(:scissor, :loose), do: :paper

  def policy(:X), do: :loose
  def policy(:Y), do: :draw
  def policy(:Z), do: :win

  def play_round({x, x}), do: 3 + score(x)
  def play_round({:rock, :scissor}), do: score(:scissor)
  def play_round({:paper, :rock}), do: score(:rock)
  def play_round({:scissor, :paper}), do: score(:paper)
  def play_round({_, me}), do: 6 + score(me)

  def score(:rock), do: 1
  def score(:paper), do: 2
  def score(:scissor), do: 3

  def conv(:A), do: :rock
  def conv(:B), do: :paper
  def conv(:C), do: :scissor
  def conv(:X), do: :rock
  def conv(:Y), do: :paper
  def conv(:Z), do: :scissor

  def example() do
    [
      {:A, :Y},
      {:B, :X},
      {:C, :Z}
    ]
  end

  def input() do
    File.read!("input.txt")
    |> String.split("\n")
    |> Enum.map(fn s ->
      [a, b] = s
      |> String.split(" ")
      |> Enum.map(&String.to_atom/1)
      {a, b}
    end)
  end
end
