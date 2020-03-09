defmodule ExMmog.Game.Actions.Attack do
  @moduledoc """
  Helper module with functions which are used when player performs an attack.
  """

  @enforce_keys [:state, :name]
  defstruct action: :join, state: %{}, name: nil

  alias __MODULE__

  defimpl ExMmog.Game.Actions.Dispatch, for: Attack do
    @doc """
    Protocol implementation for attack action.

    Takes the player name, finds other players in the attack radius and kills them.
    """

    alias ExMmog.Board

    @spec perform(%{name: any, state: atom | %{active_players: any}}) ::
            {:error, :player_not_active}
            | %{active_players: [any], board: atom | %{all: any}, dead_players: any, state: any}
    def perform(%{state: state, name: name}) do
      with true <- name in state.active_players,
           current_position <- Map.get(state.state, name),
           other_players <- find_other_players_near(state, current_position, name) do
        do_attack(state, other_players)
      else
        false ->
          {:error, :player_not_active}

        {:error, reason} ->
          {:error, reason}
      end
    end

    defp find_other_players_near(state, position, name)
         when is_map(state) and is_tuple(position) and is_binary(name) do
      radius = Board.neighbours(position, state.board().all)

      Enum.reduce(state.state, [], fn {player, player_position}, state ->
        if player_position in radius and name != player, do: [player | state], else: state
      end)
    end

    defp do_attack(state, other_players) when is_map(state) and is_list(other_players) do
      active_players = Enum.reject(state.active_players, &(&1 in other_players))
      dead_players = other_players ++ state.dead_players

      state
      |> update_active_players(active_players)
      |> update_dead_players(dead_players)
    end

    defp update_active_players(state, players), do: %{state | active_players: players}

    defp update_dead_players(state, players),
      do: %{state | dead_players: players ++ state.dead_players}
  end
end
