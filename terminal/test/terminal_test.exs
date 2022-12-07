defmodule TerminalTest do
  use ExUnit.Case
  doctest Terminal

  test "example" do
    assert Terminal.part1("example.txt") == 95437
  end

  test "input" do
    fs =
      "input.txt"
      |> Terminal.input()
      |> Terminal.gen_fs()

    assert Map.get(fs, "nmtjtd") == 47477 + 51081
    assert Map.get(fs, "pwg") == 44300 + 280_845 + 229_605 + 2053 + 143_522
  end
end
