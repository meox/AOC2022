defmodule Climb do
  @moduledoc """
  Documentation for `Climb`.
  """

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    {s_pos, e_pos, m} =
      filename
      |> input()

    dists = find_path(s_pos, m)
    Map.get(dists, e_pos)
  end

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    {_s_pos, e_pos, m} =
      filename
      |> input()

    [{_, steps}] =
      m
      |> Enum.filter(fn
        {_k, 0} -> true
        _ -> false
      end)
      |> Enum.map(fn {s_pos, 0} ->
        dists = find_path(s_pos, m)

        case Map.get(dists, e_pos) do
          nil -> nil
          {d, _} -> {s_pos, d}
        end
      end)
      |> Enum.reject(fn
        nil -> true
        _ -> false
      end)
      |> Enum.sort(fn {_, a}, {_, b} -> a < b end)
      |> Enum.take(1)

    steps
  end

  def find_path(s_pos, m) do
    visited = MapSet.new()
    unvisited = MapSet.new(Map.keys(m))
    dists = %{s_pos => {0, nil}}
    dijstra(s_pos, m, visited, unvisited, dists)
  end

  def dijstra(v, m, visited, unvisited, dists) do
    case MapSet.size(unvisited) do
      0 ->
        dists

      _ ->
        dijstra2(v, m, visited, unvisited, dists)
    end
  end

  def dijstra2([] = _v, _m, _visited, _unvisited, dists), do: dists
  def dijstra2([v], m, visited, unvisited, dists), do: dijstra2(v, m, visited, unvisited, dists)

  def dijstra2(v, m, visited, unvisited, dists) do
    ns =
      v
      |> next_moves(m)
      |> Enum.reject(&MapSet.member?(visited, &1))

    {cdist, _} = Map.get(dists, v)
    new_dist = cdist + 1

    # update dists
    new_dists =
      ns
      |> Enum.reduce(
        dists,
        fn p, acc ->
          case Map.get(acc, p, :inf) do
            :inf ->
              Map.put(acc, p, {new_dist, v})

            {dist, _last_v} when new_dist < dist ->
              Map.put(acc, p, {new_dist, v})

            _ ->
              acc
          end
        end
      )

    new_visited = MapSet.put(visited, v)
    new_unvisited = MapSet.delete(unvisited, v)

    # choose the next node
    next_v =
      new_dists
      |> Enum.filter(fn {k, _} -> MapSet.member?(new_unvisited, k) end)
      |> Enum.map(fn {p, _v} ->
        {d, _} = Map.get(new_dists, p)
        {p, d}
      end)
      |> Enum.sort(fn {_, d1}, {_, d2} -> d1 < d2 end)
      |> Enum.map(fn {nv, _} -> nv end)
      |> Enum.take(1)

    dijstra(next_v, m, new_visited, new_unvisited, new_dists)
  end

  def next_moves({x, y} = p, m) do
    level = Map.get(m, p)

    [
      get_v({x - 1, y}, m),
      get_v({x + 1, y}, m),
      get_v({x, y + 1}, m),
      get_v({x, y - 1}, m)
    ]
    |> Enum.filter(fn
      {_, nil} -> false
      {_, v} when v > level + 1 -> false
      _ -> true
    end)
    |> Enum.map(fn {p, _} -> p end)
  end

  def get_v(p, m) do
    {p, Map.get(m, p, nil)}
  end

  @doc """
  input function
  """
  def input(filename) do
    {_, s_pos, e_pos, m} =
      filename
      |> File.read!()
      |> String.split("\n")
      |> Enum.reduce(
        {0, nil, nil, %{}},
        fn line, {row, s_pos, e_pos, m} ->
          {_, s_pos, e_pos, nm} =
            line
            |> String.split("", trim: true)
            |> Enum.reduce(
              {0, s_pos, e_pos, m},
              fn
                "S", {col, _, e_pos, m} ->
                  {col + 1, {row, col}, e_pos, Map.put(m, {row, col}, conv("S"))}

                "E", {col, s_pos, _, m} ->
                  {col + 1, s_pos, {row, col}, Map.put(m, {row, col}, conv("E"))}

                e, {col, s_pos, e_pos, m} ->
                  {col + 1, s_pos, e_pos, Map.put(m, {row, col}, conv(e))}
              end
            )

          {row + 1, s_pos, e_pos, nm}
        end
      )

    {s_pos, e_pos, m}
  end

  def conv("S"), do: 0
  def conv("E"), do: conv("z")

  def conv(s) do
    [ch] = s |> String.to_charlist()
    ch - ?a
  end
end
