defmodule ExMmog.Game.Actions.Attack do
  @moduledoc """
  Helper module with functions which are used when player performs an attack.
  """

  alias ExMmog.Board

  @doc """
  Takes a player name and performs an attack action.
  """
  @spec perform(%{active_players: any}, binary) ::
          {:error, :player_not_active}
          | %{
              active_players: nonempty_maybe_improper_list,
              board: atom | %{all: any},
              dead_players: nonempty_maybe_improper_list,
              state: any
            }

  def perform(state, name) when is_binary(name) and is_map(state) do
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

    Enum.reduce(state.state, [], fn {player, _position}, state ->
      if position in radius and name != player, do: [player | state], else: state
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
