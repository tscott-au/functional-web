defmodule CoordinateTest do
  use ExUnit.Case
  doctest IslandsEngine

  test "checks coordinate happy path" do
    assert {:ok, %IslandsEngine.Coordinate{col: 1, row: 1 }} == IslandsEngine.Coordinate.new(1,1)

  end
end
