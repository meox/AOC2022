defmodule Terminal do
  @moduledoc """
  Documentation for `Terminal`.
  """

  @total_size 70_000_000
  @needed 30_000_000

  def part1(filename) do
    filename
    |> input()
    |> gen_fs()
    |> Map.values()
    |> Enum.filter(fn
      v when v <= 100_000 -> true
      _ -> false
    end)
    |> Enum.sum()
  end

  def part2(filename) do
    fs =
      filename
      |> input()
      |> gen_fs()

    occupy = Map.get(fs, "/")
    free = @total_size - occupy
    to_delete = @needed - free

    fs
    |> Enum.filter(fn {_k, v} when v >= to_delete -> true; _ -> false end)
    |> Enum.min(fn {_k1, v1}, {_k2, v2} -> v1 < v2 end)
  end

  def gen_fs(cmds) do
    state = %{
      path: ["/"],
      fs: %{}
    }

    cmds
    |> Enum.reduce(
      state,
      fn
        %{cmd: :cd, path: "/"}, state ->
          %{state | path: ["/"]}

        %{cmd: :cd, path: ".."}, %{path: [_ | full_path]} = state ->
          %{state | path: full_path}

        %{cmd: :cd, path: path}, %{path: full_path} = state ->
          %{state | path: [path | full_path]}

        %{type: :file, size: size}, %{path: path, fs: fs} = state ->
          all_paths = all_paths(path)
          new_fs =
            all_paths
            |> Enum.reduce(
              fs,
              fn x, acc ->
                Map.update(acc, x, size, &(&1 + size))
              end
            )

          %{state | fs: new_fs}

        _, state ->
          state
      end
    )
    |> then(fn %{fs: fs} -> fs end)
  end

  def all_paths(token_path), do: all_paths(token_path, [])

  def all_paths([], acc), do: acc
  def all_paths([_h | t] = p, acc) do
    np = p |> Enum.join("/")
    all_paths(t, [np | acc])
  end


  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&parse_input/1)
  end

  def parse_input("$ " <> cmd) do
    case String.split(cmd, " ") do
      ["ls"] ->
        %{cmd: :ls}

      ["cd", path] ->
        %{cmd: :cd, path: path}
    end
  end

  def parse_input("dir " <> path), do: %{type: :dir, path: path}

  def parse_input(line) do
    [size_str, name] = String.split(line, " ")
    {s, ""} = Integer.parse(size_str)
    %{type: :file, size: s, name: name}
  end
end
