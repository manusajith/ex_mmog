defmodule ExMmog.Game.Actions.Join do
  @moduledoc """
  Helper module with functions which are used when a player joins the game.
  """

  alias ExMmog.Board
  alias ExMmog.Game.State

  @doc """
  Takes a player name assigns a random position in the game.
  """
  @spec perform(State.t(), binary) :: State.t()
  def perform(state, name) when is_binary(name) and is_map(state) do
    with true <- name in state.active_players do
      state
    else
      false ->
        state
        |> start_player_at_random_position(name)
        |> update_active_players(name)
    end
  end

  defp start_player_at_random_position(state, name) do
    position = Board.start(state.board)

    %{state | state: Map.put(state.state, name, position)}
  end

  defp update_active_players(%{active_players: active_players} = initial_state, player) do
    %{initial_state | active_players: [player | active_players]}
  end
end
