defmodule GameTest do
  use ExUnit.Case
  alias IslandsEngine.{Game,  Island,  Coordinate}

  test "init" do
    {:ok, game } = Game.start_link("fred")
    state = :sys.get_state(game)
    assert state.player1.name == "fred"

  end

  test "player2" do
    {:ok, game } = Game.start_link("fred")
    Game.add_player(game, "betty")

    state  = :sys.get_state(game)
    assert state.player2.name == "betty"

  end


  test "position a island" do
    {:ok, game } = Game.start_link("fred")
    Game.add_player(game, "betty")
    error = Game.position_island(game, :player1, :square, 1, 1)
    assert error == :ok
    state = :sys.get_state(game)
    c = state.player1.board.square.coordinates
    assert MapSet.member?(c, %IslandsEngine.Coordinate{col: 1, row: 1})
  end

  defp assert_state(game, state) do
    s = :sys.get_state(game)
    assert s.rules.state == state
  end

  test "states" do
    {:ok, game } = Game.start_link("fred")
    assert_state(game, :initialized)

    Game.add_player(game, "betty")
    assert_state(game, :players_set)

    add_islands(game, :player2, :pattern1)
    assert_state(game, :players_set)

    add_islands(game, :player1, :pattern1)
    assert_state(game, :players_set)

    Game.position_island(game, :player1, :square, 1, 3)
    assert_state(game, :players_set)

    Game.set_islands(game, :player1)
    assert_state(game, :players_set)

    Game.set_islands(game, :player2)
    assert_state(game, :player1_turn)


    # state = :sys.replace_state(game, fn state_data -> %{state_data | rules: %Rules{state: :player1_turn}} end)
    # assert state.rules.state == :player1_turn

    # assert {:error, "default"} == Game.position_island(game, :player1, :dot, 10, 1 )

  end

  test "position islands" do
    {:ok, game } = Game.start_link("fred")
    Game.add_player(game, "betty")
    error = Game.position_island(game, :player1, :square, 1, 1)
    assert error == :ok
    error = Game.position_island(game, :player1, :square, 2, 2)
    assert error == :ok
    error = Game.position_island(game, :player1, :square, 4, 3)
    assert error == :ok
    error = Game.position_island(game, :player1, :square, 4, 4)
    assert error == :ok
    state = :sys.get_state(game)
    c = state.player1.board.square.coordinates
    assert MapSet.member?(c, %IslandsEngine.Coordinate{col: 4, row: 4})
    assert Map.size(state.player1.board) == 1
  end


  test "set islands" do
    game = new_game()
    add_islands(game, :player1, :pattern1)

    error = Game.set_islands(game, :player2)
    assert error == :not_all_islands_positioned
    add_islands(game, :player2, :pattern1)

    {error, _board} = Game.set_islands(game, :player1)
    assert error == :ok

    {error, _board} = Game.set_islands(game, :player1)
    assert error == :ok

  end



  test "guess" do
    game = new_game()
    add_islands(game, :player1, :pattern1)
    add_islands(game, :player2, :pattern1)
    set_islands(game, :player1)
    set_islands(game, :player2)

    error = Game.guess_coordinate(game, :player1, 1, 3)
    assert error == {:miss, :none, :no_win}

    error = Game.guess_coordinate(game, :player2, 1, 1)
    assert error == {:hit, :none, :no_win}

    error = Game.guess_coordinate(game, :player2, 1, 2)
    assert error == :error

    error = Game.guess_coordinate(game, :player1, 5, 3)
    assert error == {:hit, :none, :no_win}

  end

  test "win" do
    game = new_game()
    add_islands(game, :player1, :pattern1)
    add_islands(game, :player2, :pattern1)
    set_islands(game, :player1)
    set_islands(game, :player2)
    %Coordinate{row: row, col: col} = almost_win(game)

    {_hit_mis, _island, win} = Game.guess_coordinate(game, :player1, row, col)
    assert win == :win
  end

  test "registry" do
    name = "barny-" <> Integer.to_string(:os.system_time(:millisecond))
    new_game(name)
    via = Game.via_tuple(name)
    state = :sys.get_state(via)
    assert state.player1.name == name
  end



  defp new_game(name \\ "fred") do
    {:ok, game } = Game.start_link(name)
    error = Game.add_player(game, "betty")
    assert error == :ok
    game
  end

  defp add_islands(game, player, :pattern1) do
    error = Game.position_island(game, player, :square, 1, 1)
    assert error == :ok
    error = Game.position_island(game, player, :dot, 10, 1)
    assert error == :ok
    error = Game.position_island(game, player, :atoll, 5, 3)
    assert error == :ok
    error = Game.position_island(game, player, :l_shape, 7, 1)
    assert error == :ok
    error = Game.position_island(game, player, :s_shape, 9, 8)
    assert error == :ok
  end

  defp set_islands(game, player) do
    {error, _board} = Game.set_islands(game, player)
    assert error == :ok
  end

  defp almost_win(game) do
    {player1_last, coords} = get_coords(game, :player1)
      |> List.pop_at(0)

    Enum.each(coords, fn %Coordinate{row: row, col: col} ->
      Game.guess_coordinate(game, :player1, row, col )
      Game.guess_coordinate(game, :player2, 1, 1 )
      end )
    player1_last
  end

  defp get_coords(game, player) do
    state = :sys.get_state(game)
    Map.get(state, player).board
    |> Map.values
    |> Enum.map(fn %Island{coordinates: c, hit_coordinates: _h} -> MapSet.to_list(c) end)
    |> List.flatten
  end

end
