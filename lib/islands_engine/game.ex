#---
# Excerpted from "Functional Web Development with Elixir, OTP, and Phoenix",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/lhelph for more book information.
#---
defmodule IslandsEngine.Game do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  alias IslandsEngine.{Board, Coordinate, Guesses, Island, Rules}

  @players [:player1, :player2]



  def start_link(name) when is_binary(name), do:
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))

  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil,  board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: %Rules{}}}
    |> with_timeout
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def add_player(game, name) when is_binary(name), do:
    GenServer.call(game, {:add_player, name})

  def position_island(game, player, key, row, col) when player in @players, do:
    GenServer.call(game, {:position_island, player, key, row, col})

  def set_islands(game, player) when player in @players, do:
    GenServer.call(game, {:set_islands, player})

  def guess_coordinate(game, player, row, col) when player in @players, do:
    GenServer.call(game, {:guess_coordinate, player, row, col})


  def handle_call({:add_player, name}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, :add_player)
    do
      state_data
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state_data}
      {:error, _msg} -> {:reply, :error, state_data}
    end
    |> with_timeout
  end

  def handle_call({:position_island, player, key, row, col}, _from, state_data)
  do
    board = player_board(state_data, player)
    with  {:ok, rules} <-
            Rules.check(state_data.rules, {:position_islands, player}),
          {:ok, coordinate} <-
            Coordinate.new(row, col),
          {:ok, island} <-
            Island.new(key, coordinate),
          %{} = board <-
            Board.position_island(board, key, island)
    do
      state_data
      |> update_board(player, board)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state_data}
      {:error, :invalid_coordinate} ->
        {:reply, {:error, :invalid_coordinate}, state_data}
      {:error, :invalid_island_type} ->
        {:reply, {:error, :invalid_island_type}, state_data}
      {:error, msg} -> {:reply, {:error, msg}, state_data}
    end
    |> with_timeout
  end

  def handle_call({:set_islands, player}, _from, state) do
    board = player_board(state, player)
    with {:ok, rules} <- Rules.check(state.rules, {:set_islands, player}),
      true <- Board.all_islands_positioned?(board)
    do
      state
      |> update_rules(rules)
      |> reply_success({:ok, board})
    else
      :error -> {:reply, :error, state}
      false -> {:reply, :not_all_islands_positioned, state}
      {:error, _msg} -> {:reply, :error, state}
    end
    |> with_timeout
  end

  def handle_call({:guess_coordinate, player, row, col}, _from, state) do
    opponent = get_opponent(player)
    board = player_board(state, opponent)

    with {:ok, rules} <- Rules.check(state.rules, {:guess_coordinate, player}),
      {:ok, coordinate} <- Coordinate.new(row, col),
      {hit_or_miss, forested_island, win_status, board} <- Board.guess(board, coordinate),
      {:ok, rules} <- Rules.check(rules, {:win_check, win_status})
    do
      state
      |> update_board(opponent, board)
      |> update_guesses(player, hit_or_miss, coordinate)
      |> update_rules(rules)
      |> reply_success({hit_or_miss, forested_island, win_status})
    else
      :error -> {:reply, :error, state}
      {:error, :invalid_coordinate} ->
        {:reply, {:error, :invalid_coordinate}, state}

      {:error, _msg} -> {:reply, :error, state}
    end
    |> with_timeout
  end

  def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}


  defp update_player2_name(state_data, name), do:
    put_in(state_data.player2.name, name)

  defp update_rules(state_data, rules), do: %{state_data | rules: rules}

  defp update_board(state_data, player, board), do:
    Map.update!(state_data, player, fn player -> %{player | board: board} end)

  defp update_guesses(state_data, player, hit_or_miss, coordinate) do
    update_in(state_data[player].guesses, fn guesses ->
      Guesses.add(guesses, hit_or_miss, coordinate)
    end)
  end


  defp reply_success(state_data, reply), do: {:reply, reply, state_data}
  def with_timeout(reply), do: reply |> Tuple.append(Application.get_env(:islands_engine, :timeout))

  defp player_board(state_data, player), do: Map.get(state_data, player).board

  defp get_opponent(:player1), do: :player2

  defp get_opponent(:player2), do: :player1

end
