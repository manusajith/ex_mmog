defmodule ExMmog.Game.Actions.Cleanup do
  @moduledoc """
  Helper module with functions which are used to cleanup the players
  at reguler intervals and re-spawn them.
  """

  alias ExMmog.Board

  @doc """
  Performs cleanup of the board, removes dead players and re-spawn them at random position.
  """
  @spec perform(%{active_players: [any], dead_players: any}) :: %{
          active_players: [],
          dead_players: any,
          state: map
        }
  def perform(state) do
    active_players = state.active_players ++ state.dead_players

    updated_state =
      Enum.reduce(state.dead_players, %{}, fn name, %{} ->
        random_position(state, name)
      end)

    state
    |> update_active_players(active_players)
    |> update_dead_players([])
    |> update_state(updated_state)
  end

  defp random_position(state, name) do
    position = Board.start(state.board)

    %{name => position}
  end

  defp update_active_players(state, players), do: %{state | active_players: players}

  defp update_dead_players(state, players), do: %{state | dead_players: players}

  defp update_state(state, updated_state) do
    game_state = Map.merge(state.state, updated_state)

    %{state | state: game_state}
  end
end
