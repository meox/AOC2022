defmodule Trees do
  @moduledoc """
  Documentation for `Trees`.
  """

  def part1() do
    table =
      "input.txt"
      |> input()

    table_map = to_map(table)
    rows = length(table)
    cols = length(Enum.at(table, 0))

    vs =
      for r <- 1..(rows - 2), c <- 1..(cols - 2) do
        h_ref = Map.get(table_map, {r, c})

        v =
          visible_up(h_ref, r, c, table_map) or
            visible_down(h_ref, r, c, table_map, rows - 1) or
            visible_left(h_ref, r, c, table_map) or
            visible_right(h_ref, r, c, table_map, cols - 1)

        {{r, c}, v}
      end

    inner =
      vs
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.count()

    outer = 2 * (cols + rows - 2)
    inner + outer
  end

  def part2() do
    table =
      "input.txt"
      |> input()

    table_map = to_map(table)
    rows = length(table)
    cols = length(Enum.at(table, 0))

    vs =
      for r <- 1..(rows - 2), c <- 1..(cols - 2) do
        h_ref = Map.get(table_map, {r, c})

        v =
          count_up(h_ref, r, c, table_map) *
            count_down(h_ref, r, c, table_map, rows - 1) *
            count_left(h_ref, r, c, table_map) *
            count_right(h_ref, r, c, table_map, cols - 1)

        {{r, c}, v}
      end

    vs
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.max()
  end

  def h_selector(h_ref, r, c, table_map, acc) do
    case Map.get(table_map, {r, c}) do
      ^h_ref -> {:halt, acc + 1}
      h when h < h_ref -> {:cont, acc + 1}
      _ -> {:halt, acc + 1}
    end
  end

  def count_up(h_ref, r, c, table_map) do
    (r - 1)..0
    |> Enum.reduce_while(0, fn nr, acc ->
      h_selector(h_ref, nr, c, table_map, acc)
    end)
  end

  def count_down(h_ref, r, c, table_map, l) do
    (r + 1)..l
    |> Enum.reduce_while(0, fn nr, acc ->
      h_selector(h_ref, nr, c, table_map, acc)
    end)
  end

  def count_left(h_ref, r, c, table_map) do
    (c - 1)..0
    |> Enum.reduce_while(0, fn nc, acc ->
      h_selector(h_ref, r, nc, table_map, acc)
    end)
  end

  def count_right(h_ref, r, c, table_map, l) do
    (c + 1)..l
    |> Enum.reduce_while(0, fn nc, acc ->
      h_selector(h_ref, r, nc, table_map, acc)
    end)
  end

  def visible_up(h_ref, r, c, table_map) do
    (r - 1)..0
    |> Enum.all?(fn nr -> h_ref > Map.get(table_map, {nr, c}) end)
  end

  def visible_down(h_ref, r, c, table_map, l) do
    (r + 1)..l
    |> Enum.all?(fn nr -> h_ref > Map.get(table_map, {nr, c}) end)
  end

  def visible_left(h_ref, r, c, table_map) do
    (c - 1)..0
    |> Enum.all?(fn nc -> h_ref > Map.get(table_map, {r, nc}) end)
  end

  def visible_right(h_ref, r, c, table_map, l) do
    (c + 1)..l
    |> Enum.all?(fn nc -> h_ref > Map.get(table_map, {r, nc}) end)
  end

  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split("", trim: true)
      |> Enum.map(fn e ->
        {h, ""} = Integer.parse(e)
        h
      end)
    end)
  end

  def to_map(table) do
    {_, tmap} =
      table
      |> Enum.reduce(
        {0, %{}},
        fn row, {row_id, acc} ->
          {_, new_acc} =
            row
            |> Enum.reduce(
              {0, acc},
              fn h, {col_id, acc} ->
                {col_id + 1, Map.put(acc, {row_id, col_id}, h)}
              end
            )

          {row_id + 1, new_acc}
        end
      )

    tmap
  end
end
