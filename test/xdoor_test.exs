defmodule XdoorTest do
  use ExUnit.Case
  doctest Xdoor

  test "greets the world" do
    assert Xdoor.hello() == :world
  end
end
