defmodule GuessesTest do
  use ExUnit.Case
  alias IslandsEngine.{Coordinate, Guesses}
  ## doctest Guesses


  test "Test guesses" do
    guesses = Guesses.new
    {:ok, coordinate1} = Coordinate.new(1, 1)
    {:ok, coordinate2} = Coordinate.new(2, 2)
    {:ok, coordinate3} = Coordinate.new(1, 1)
    guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate1))
    guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate2))
    guesses = update_in(guesses.hits, &MapSet.put(&1, coordinate3))

    assert MapSet.size(guesses.hits) == 2

  end
end
