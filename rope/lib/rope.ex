defmodule Rope do
  @moduledoc """
  Documentation for `Rope`.
  """

  def part1(filename) do
    {_, _, grid} =
      filename
      |> input()
      |> Enum.reduce(
        {{0, 0}, {0, 0}, %{{0, 0} => true}},
        fn {dir, n}, {h, t, grid} ->
          move(dir, n, h, t, grid)
        end
      )

    grid |> map_size()
  end

  def part2(filename) do
    ropes = for _x <- 0..9, do: {0, 0}

    {_, grid} =
      filename
      |> input()
      |> Enum.reduce(
        {ropes, %{{0, 0} => true}},
        fn {dir, n}, {ropes, grid} ->
          move_multi(dir, n, ropes, grid)
        end
      )

    grid |> map_size()
  end

  def move_multi(_dir, 0, ropes, grid), do: {ropes, grid}

  def move_multi(dir, n, ropes, grid) do
    updates = update_pos(dir, ropes, [])
    new_ropes = updates ++ Enum.drop(ropes, length(updates))


    pos_t = Enum.at(new_ropes, 9)
    new_grid = Map.put(grid, pos_t, true)

    move_multi(dir, n - 1, new_ropes, new_grid)
  end

  def update_pos(_dir, [], acc), do: Enum.reverse(acc)

  def update_pos(dir, [h, t | ropes], []) do
    nh = update_head(dir, h)

    nt =
      case touch(nh, t) do
        true ->
          t

        _ ->
          update_tail(nh, t)
      end

    case nt do
      ^t ->
        [nh]

      _ ->
        update_pos(dir, ropes, [nt, nh])
    end
  end

  def update_pos(dir, [t | ropes], [nh | _] = acc) do
    nt =
      case touch(nh, t) do
        true ->
          t

        _ ->
          update_tail(nh, t)
      end

    case nt do
      ^t ->
        acc |> Enum.reverse()

      _ ->
        update_pos(dir, ropes, [nt | acc])
    end
  end

  def move(_dir, 0, h, t, grid), do: {h, t, grid}

  def move(dir, n, h, t, grid) do
    nh = update_head(dir, h)

    nt =
      case touch(nh, t) do
        true ->
          t

        _ ->
          update_tail(nh, t)
      end

    move(dir, n - 1, nh, nt, Map.put(grid, nt, true))
  end

  def update_head(:r, {xh, yh}), do: {xh + 1, yh}
  def update_head(:l, {xh, yh}), do: {xh - 1, yh}
  def update_head(:u, {xh, yh}), do: {xh, yh + 1}
  def update_head(:d, {xh, yh}), do: {xh, yh - 1}

  def update_tail({xh, y}, {xt, y}) when xh > xt, do: {xt + 1, y}
  def update_tail({xh, y}, {xt, y}) when xt > xh, do: {xt - 1, y}
  def update_tail({x, yh}, {x, yt}) when yh > yt, do: {x, yt + 1}
  def update_tail({x, yh}, {x, yt}) when yt > yh, do: {x, yt - 1}

  def update_tail({xh, yh}, {xt, yt}) when xh - xt == 2 and yh > yt do
    {xt + 1, yt + 1}
  end
  def update_tail({xh, yh}, {xt, yt}) when xh - xt == 2 and yh < yt do
    {xt + 1, yt - 1}
  end

  def update_tail({xh, yh}, {xt, yt}) when xt - xh == 2 and yh > yt do
    {xt - 1, yt + 1}
  end
  def update_tail({xh, yh}, {xt, yt}) when xt - xh == 2 and yh < yt do
    {xt - 1, yt - 1}
  end

  def update_tail({xh, yh}, {xt, yt}) when xh > xt and yh - yt == 2 do
    {xt + 1, yt + 1}
  end
  def update_tail({xh, yh}, {xt, yt}) when xh < xt and yh - yt == 2 do
    {xt - 1, yt + 1}
  end

  def update_tail({xh, yh}, {xt, yt}) when xh > xt and yt - yh == 2 do
    {xt + 1, yt - 1}
  end
  def update_tail({xh, yh}, {xt, yt}) when xh < xt and yt - yh == 2 do
    {xt - 1, yt - 1}
  end


  def touch({xh, yh}, {xt, yt}) do
    abs(xt - xh) <= 1 and abs(yt - yh) <= 1
  end

  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [dir, s] = String.split(line, " ")
      {n, ""} = Integer.parse(s)
      {String.to_atom(String.downcase(dir)), n}
    end)
  end
end
