defmodule Stacks do
  @moduledoc """
  Documentation for `Stacks`.
  """

  def part1(), do: process(&apply_rule/2)

  def part2(), do: process(&apply_rule_9001/2)

  def process(engine) do
    instrs = input("input.txt")
    init_conf = input_conf()

    instrs
    |> Enum.reduce(
      init_conf,
      fn instr, conf -> engine.(conf, instr) end
    )
    |> final_state()
  end

  def final_state(state) do
    state
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map(fn idx ->
      [ch | _] = Map.get(state, idx)
      :erlang.atom_to_list(ch)
    end)
    |> Enum.join()
  end

  def apply_rule_9001(conf, %{from: from, to: to, n: n}) do
    {to_move, remains} = conf |> Map.get(from) |> Enum.split(n)
    col_t = Map.get(conf, to)
    %{conf | from => remains, to => to_move ++ col_t}
  end

  def apply_rule(conf, %{from: from, to: to, n: n}) do
    col_f = Map.get(conf, from)
    col_t = Map.get(conf, to)

    {col_from, col_to} =
      Enum.reduce(
        1..n,
        {col_f, col_t},
        fn _x, {c1, c2} ->
          move(c1, c2)
        end
      )

    %{conf | from => col_from, to => col_to}
  end

  def move([h | t], to), do: {t, [h | to]}

  #        [G]         [D]     [Q]
  #[P]     [T]         [L] [M] [Z]
  #[Z] [Z] [C]         [Z] [G] [W]
  #[M] [B] [F]         [P] [C] [H] [N]
  #[T] [S] [R]     [H] [W] [R] [L] [W]
  #[R] [T] [Q] [Z] [R] [S] [Z] [F] [P]
  #[C] [N] [H] [R] [N] [H] [D] [J] [Q]
  #[N] [D] [M] [G] [Z] [F] [W] [S] [S]
  # 1   2   3   4   5   6   7   8   9

  def input_conf() do
    %{
      1 => ~w(P Z M T R C N)a,
      2 => ~w(Z B S T N D)a,
      3 => ~w(G T C F R Q H M)a,
      4 => ~w(Z R G)a,
      5 => ~w(H R N Z)a,
      6 => ~w(D L Z O W S H F)a,
      7 => ~w(M G C R Z D W)a,
      8 => ~w(Q Z W H L F J S)a,
      9 => ~w(N W P Q S)a,
    }
  end

  def example_conf() do
    %{
      1 => [:N, :Z],
      2 => [:D, :C, :M],
      3 => [:P]
    }
  end

  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&parse/1)
  end

  def parse(line) do
    %{
      "from" => from,
      "n" => n,
      "to" => to
    } = Regex.named_captures(~r/move (?<n>\d+) from (?<from>\d+) to (?<to>\d+)/, line)

    {from_n, _} = Integer.parse(from)
    {to_n, _} = Integer.parse(to)
    {n_n, _} = Integer.parse(n)

    %{
      :from => from_n,
      :to => to_n,
      :n => n_n
    }
  end
end
