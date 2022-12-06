defmodule SignalTest do
  use ExUnit.Case
  doctest Signal

  test "start marker" do
    assert Signal.find_start_marker("bvwbjplbgvbhsrlpgdmjqwftvncz", 4) == 5
    assert Signal.find_start_marker("nppdvjthqldpwncqszvftbrmjlhg", 4) == 6
    assert Signal.find_start_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 4) == 10
    assert Signal.find_start_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 4) == 11
  end
end
