defmodule ExMmog.Game.Actions.Move do
  @moduledoc """
  Helper module with functions which are used to move the player around in the game.
  """

  @doc """
  Takes a player name, and direction and move the player in the board.
  """
  @spec perform(%{active_players: any}, binary, atom) ::
          {:error, :bad_position | :player_not_active}
          | %{active_players: any, board: any, state: map}
  def perform(state, name, direction)
      when is_binary(name) and is_map(state) and is_atom(direction) do
    with true <- name in state.active_players,
         current_position <- Map.get(state.state, name),
         {:ok, new_position} <- do_move_to(current_position, direction, state.board) do
      update_state(state, name, new_position)
    else
      false ->
        {:error, :player_not_active}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_move_to(position, :up, board), do: do_move_to(position, -1, 0, board)
  defp do_move_to(position, :down, board), do: do_move_to(position, 1, 0, board)
  defp do_move_to(position, :right, board), do: do_move_to(position, 0, 1, board)
  defp do_move_to(position, :left, board), do: do_move_to(position, 0, -1, board)

  defp do_move_to({row, column}, row_offset, column_offset, board) do
    case valid_position?({row + row_offset, column + column_offset}, board) do
      {:error, reason} ->
        {:error, reason}

      {:ok, _} ->
        {:ok, {row + row_offset, column + column_offset}}
    end
  end

  defp update_state(state, name, position) do
    %{state | state: Map.put(state.state, name, position)}
  end

  defp valid_position?({row, _column}, _board) when row < 0, do: {:error, :bad_position}
  defp valid_position?({_row, column}, _board) when column < 0, do: {:error, :bad_position}

  defp valid_position?({row, column}, board) do
    case MapSet.member?(board.walkable, {row, column}) do
      true -> {:ok, {row, column}}
      false -> {:error, :bad_position}
    end
  end
end
