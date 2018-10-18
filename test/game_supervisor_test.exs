defmodule GameSupervisorTest do
  use ExUnit.Case
  alias IslandsEngine.{Game, GameSupervisor}

  @tag :wip
  test "sup start"  do

    name = "freddy"
    {ok, _game} = GameSupervisor.start_game(name)
    assert ok == :ok

    via = Game.via_tuple(name)
    assert via == {:via, Registry, {Registry.Game, name}}

    stats = Supervisor.count_children(GameSupervisor)
    assert stats.workers == 1

    {ok, game} = GameSupervisor.start_game(name)
    assert ok == :error
    assert :already_started == elem(game, 0)

    result = GameSupervisor.stop_game(name)
    assert result == :ok

    stats = Supervisor.count_children(GameSupervisor)
    assert stats.workers == 0



  end



end
