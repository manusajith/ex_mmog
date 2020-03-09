defmodule ExMmog.Game.Actions.Cleanup do
  @moduledoc """
  Helper module with functions which are used to cleanup the players
  at reguler intervals and re-spawn them.
  """

  @enforce_keys [:state, :inactive_players]
  defstruct action: :cleanup, state: %{}, inactive_players: []

  alias __MODULE__

  defimpl ExMmog.Game.Actions.Dispatch, for: Cleanup do
    @doc """
    Protocol implementation for cleanup action.

    Iterate over the dead players and re-spawn them at random places
    if the player is still actively connected to the game.
    """

    alias ExMmog.Board

    @spec perform(%{inactive_players: [any], state: %{active_players: any, dead_players: any}}) ::
            %{active_players: any, dead_players: [], state: map}
    def perform(%{state: state, inactive_players: inactive_players}) do
      players_to_re_spawn = players_to_re_spawn(state, inactive_players)
      re_spawned_players = re_spawned_players(state, players_to_re_spawn)
      active_players = players_to_re_spawn ++ state.active_players

      state
      |> update_dead_players([])
      |> remove_inactive_dead_players(inactive_players)
      |> re_spawn_dead_players(re_spawned_players)
      |> update_active_players(active_players)
    end

    defp random_position(state, name) do
      position = Board.start(state.board)

      %{name => position}
    end

    defp update_active_players(state, players), do: %{state | active_players: players}

    defp update_dead_players(state, players), do: %{state | dead_players: players}

    defp re_spawn_dead_players(state, updated_state) do
      game_state = Map.merge(state.state, updated_state)

      %{state | state: game_state}
    end

    defp remove_inactive_dead_players(state, players) do
      %{state | state: Map.drop(state.state, players)}
    end

    defp re_spawned_players(state, players_to_respawn) do
      Enum.reduce(players_to_respawn, %{}, fn name, %{} ->
        random_position(state, name)
      end)
    end

    defp players_to_re_spawn(state, inactive_players) do
      Enum.filter(state.dead_players, &(&1 not in inactive_players))
    end
  end
end
