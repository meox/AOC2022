defmodule Cubes do
  @moduledoc """
  Documentation for `Cubes`.
  """

  def part1(:mini), do: part1("mini.txt")
  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    filename
    |> input()
    |> boiling()
    |> Enum.filter(fn {_k, v} -> v == 1 end)
    |> Enum.count()
  end

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    cubes =
      filename
      |> input()

    boiled =
      cubes
      |> boiling()
      |> Enum.filter(fn {_k, v} -> v == 1 end)
      |> Enum.count()

    box =
      {{min_x, min_y, min_z}, {max_x, max_y, max_z}} =
      cubes
      |> Enum.reduce(
        {{nil, nil, nil}, {nil, nil, nil}},
        fn [x, y, z], {{min_x, min_y, min_z}, {max_x, max_y, max_z}} ->
          {
            {nmin(x, min_x), nmin(y, min_y), nmin(z, min_z)},
            {nmax(x, max_x), nmax(y, max_y), nmax(z, max_z)}
          }
        end
      )

    cubes_map =
      cubes
      |> Enum.reduce(%{}, fn [x, y, z], acc -> Map.put(acc, {x, y, z}, true) end)

    all_cubes = for x <- min_x..max_x, y <- min_y..max_y, z <- min_z..max_z, do: [x, y, z]

    all_cubes =
      all_cubes
      |> Enum.reject(fn [x, y, z] ->
        Map.get(cubes_map, {x, y, z}, false)
      end)

    air_surf =
      all_cubes
      |> air_cubes(cubes_map, box)
      |> boiling()
      |> Enum.filter(fn {_k, v} -> v == 1 end)
      |> Enum.count()

    boiled - air_surf
  end

  def nmin(nil, x), do: x
  def nmin(x, nil), do: x
  def nmin(x, y), do: min(x, y)

  def nmax(nil, x), do: x
  def nmax(x, nil), do: x
  def nmax(x, y), do: max(x, y)

  def air_cubes(all_cubes, cubes_map, box) do
    all_cubes
    |> Enum.filter(fn cube ->
      contained?(cube, cubes_map, box)
    end)
  end

  def contained?([x, y, z], cubes_map, {{min_x, min_y, min_z}, {max_x, max_y, max_z}}) do
    [
      min_x..(x - 1) |> Enum.any?(&Map.get(cubes_map, {&1, y, z}, false)),
      (x + 1)..max_x |> Enum.any?(&Map.get(cubes_map, {&1, y, z}, false)),
      min_y..(y - 1) |> Enum.any?(&Map.get(cubes_map, {x, &1, z}, false)),
      (y + 1)..max_y |> Enum.any?(&Map.get(cubes_map, {x, &1, z}, false)),
      min_z..(z - 1) |> Enum.any?(&Map.get(cubes_map, {x, y, &1}, false)),
      (z + 1)..max_z |> Enum.any?(&Map.get(cubes_map, {x, y, &1}, false))
    ]
    |> Enum.all?()
  end

  def boiling(cubes) do
    cubes
    |> Enum.reduce(
      %{},
      fn cube, acc ->
        cube
        |> faces()
        |> Enum.reduce(
          acc,
          fn f, acc ->
            Map.update(acc, f, 1, &(&1 + 1))
          end
        )
      end
    )
  end

  def faces({x, y, z}), do: faces([x, y, z])

  def faces([x, y, z]) do
    [
      [
        {x - 0.5, y - 0.5, z - 0.5},
        {x - 0.5, y - 0.5, z + 0.5},
        {x - 0.5, y + 0.5, z - 0.5},
        {x - 0.5, y + 0.5, z + 0.5}
      ],
      [
        {x + 0.5, y - 0.5, z - 0.5},
        {x + 0.5, y - 0.5, z + 0.5},
        {x + 0.5, y + 0.5, z - 0.5},
        {x + 0.5, y + 0.5, z + 0.5}
      ],
      [
        {x - 0.5, y - 0.5, z - 0.5},
        {x - 0.5, y + 0.5, z - 0.5},
        {x + 0.5, y - 0.5, z - 0.5},
        {x + 0.5, y + 0.5, z - 0.5}
      ],
      [
        {x - 0.5, y - 0.5, z + 0.5},
        {x - 0.5, y + 0.5, z + 0.5},
        {x + 0.5, y - 0.5, z + 0.5},
        {x + 0.5, y + 0.5, z + 0.5}
      ],
      [
        {x - 0.5, y + 0.5, z - 0.5},
        {x - 0.5, y + 0.5, z + 0.5},
        {x + 0.5, y + 0.5, z - 0.5},
        {x + 0.5, y + 0.5, z + 0.5}
      ],
      [
        {x - 0.5, y - 0.5, z - 0.5},
        {x - 0.5, y - 0.5, z + 0.5},
        {x + 0.5, y - 0.5, z - 0.5},
        {x + 0.5, y - 0.5, z + 0.5}
      ]
    ]
  end

  @doc """
  input function
  """
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line -> line |> String.split(",", trim: true) |> as_numbers() end)
  end

  defp as_numbers(xs) when is_list(xs) do
    Enum.map(xs, &as_number/1)
  end

  defp as_number(s) do
    {n, ""} = Integer.parse(s)
    n
  end
end
