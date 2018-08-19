defmodule GuessesTest do
  use ExUnit.Case
  ## doctest Guesses


  test "Test guesses" do
    guesses = IslandsEngine.Guesses.new
    {:ok, coordinate1} = IslandsEngine.Coordinate.new(1, 1)
    {:ok, coordinate2} = IslandsEngine.Coordinate.new(2, 2)
    {:ok, coordinate3} = IslandsEngine.Coordinate.new(1, 1)
    guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate1))
    guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate2))
    guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate3))

    assert MapSet.size(guesses.hits) == 2

  end
end
