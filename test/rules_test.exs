
  defmodule TestV do
    defstruct 	[:name, :action, :state, :err]
  end

defmodule RulesTest do
  use ExUnit.Case
  alias IslandsEngine.Rules
  ## doctest Guesses

  test "Rules0" do
    check = :win
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}
    {:ok, rules} = Rules.check(rules, {:win_check, check} )
    assert rules.state == :game_over
  end

  test "Rules1" do

    tt = [
      %TestV{name: "no-action", err: :error},
      %TestV{name: "bad-action", action: %{x: nil}, err: :error},
      %TestV{name: "players-set", action: :add_player, state: :players_set},
      %TestV{name: "position-islands", action: {:position_islands, :player1}, state: :players_set},
      %TestV{name: "position-islands2", action: {:position_islands, :player2}, state: :players_set},
      # not valid just results in a key exception ... %TestV{name: "position-islands3", action: {:position_islands, :player3}, state: :players_set},
      %TestV{name: "set-islands", action: {:set_islands, :player2}, state: :players_set},
      %TestV{name: "set-islands2", action: {:set_islands, :player2}, state: :players_set},
      %TestV{name: "position-after-set", action: {:position_islands, :player2}, state: :players_set, err: :error},
      %TestV{name: "set-islands3", action: {:set_islands, :player1}, state: :player1_turn},
      %TestV{name: "guess", action: {:guess_coordinate, :player1}, state: :player2_turn},
      %TestV{name: "bad guess", action: {:guess_coordinate, :player1}, state: :player2_turn, err: :error},
      %TestV{name: "guess2", action: {:guess_coordinate, :player2}, state: :player1_turn},
      %TestV{name: "bad guess2", action: {:guess_coordinate, :player2}, state: :player1_turn, err: :error},
      %TestV{name: "win-false", action: {:win_check, :no_win}, state: :player1_turn},
      %TestV{name: "win-true", action: {:win_check, :win}, state: :game_over},
      #%TestV{name: "WIN-false", evt: Event{action: Win}, state: Player1Turn},
      #%TestV{name: "WIN-true", evt: Event{action: Win, win: true}, state: GameOver},
      #%TestV{name: "guess3", evt: Event{action: Guess, player: Player2}, state: GameOver, err: "missing rules function, last state: 5"}
    ]

    r = Rules.new()
    Enum.reduce(tt, r, fn tc, r ->

        case Rules.check(r, tc.action) do
          {:error, _msg} -> assert(tc.err == :error, tc.name)
          r
          {:ok, rules} -> assert(rules.state == tc.state, tc.name)
            rules

        end


    end)

  end



# defmodule StemEx.StepsTest do
#   use ExUnit.Case, async: true



  tests = [
      %TestV{name: "no-action", err: :error},
      %TestV{name: "bad-action", action: {:x }, err: :error},
      %TestV{name: "players-set", action: :add_player, state: :players_set},
      #%TestV{name: "position-islands", action: {:position_islands, :player1}, state: :players_set},
      #%RulesTest.TestV{name: "position-islands2", evt: Event{action: PositionIslands, player: Player2}, state: PlayersSet},
      #%RulesTest.TestV{name: "position-islands3", evt: Event{action: PositionIslands}, state: PlayersSet, err: "Unknown player identifier, Player:0"},
      #%RulesTest.TestV{name: "set-islands", evt: Event{action: SetIslands, player: Player2}, state: PlayersSet},
      #%RulesTest.TestV{name: "set-islands2", evt: Event{action: SetIslands, player: Player2}, state: PlayersSet},
      #%RulesTest.TestV{name: "position-after-set", evt: Event{action: PositionIslands, player: Player2}, state: PlayersSet, err: "invalid state transition for PositionIslands"},
      #%RulesTest.TestV{name: "set-islands3", evt: Event{action: SetIslands, player: Player1}, state: Player1Turn},
      #%RulesTest.TestV{name: "guess", evt: Event{action: Guess, player: Player1}, state: Player2Turn},
      #%RulesTest.TestV{name: "bad guess", evt: Event{action: Guess, player: Player1}, state: Player2Turn, err: "not turn for player 1"},
      #%RulesTest.TestV{name: "guess2", evt: Event{action: Guess, player: Player2}, state: Player1Turn},
      #%RulesTest.TestV{name: "bad guess", evt: Event{action: Guess, player: Player2}, state: Player1Turn, err: "not turn for player 2"},
      #%RulesTest.TestV{name: "WIN-false", evt: Event{action: Win}, state: Player1Turn},
      #%RulesTest.TestV{name: "WIN-true", evt: Event{action: Win, win: true}, state: GameOver},
      #%RulesTest.TestV{name: "guess3", evt: Event{action: Guess, player: Player2}, state: GameOver, err: "missing rules function, last state: 5"}
    ]

  r = Rules.new()

  for test <- tests do

    @name test.name
    @action test.action
    @state test.state
    @error test.err
    @rules r

    test "#{@name}" do
      # assert @action == :sdf
      case Rules.check(@rules, @action) do
        {:error, msg} -> assert(@error == :error, msg)
        {:ok, rules} -> assert(rules.state == @state)
        # this does not work... need a way to return state from test...@rules = rules
      end
      # result = apply(StemEx.Steps, @name, [@input])
      # assert result == @output
    end
  end

end
