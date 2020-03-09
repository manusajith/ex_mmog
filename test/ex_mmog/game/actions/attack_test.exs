defmodule ExMmog.Game.Actions.AttackTest do
  use ExUnit.Case, async: true

  alias ExMmog.Board
  alias ExMmog.Game.State
  alias ExMmog.Game.Actions.{Dispatch, Attack}

  setup do
    state = %State{}
    [state: state]
  end

  describe "perform/1" do
    setup [:manu, :geralt, :join]

    test "when a player performs an attack", %{state: state, manu: manu, geralt: geralt} do
      assert length(state.dead_players) == 0
      assert Enum.member?(state.active_players, manu)
      assert Enum.member?(state.active_players, geralt)

      {row, col} = Map.get(state.state, manu)
      updated_game_state = teleport_player_to(state.state, geralt, {row + 1, col})
      state = %{state | state: updated_game_state}

      updated_state =
        %Attack{state: state, name: manu}
        |> Dispatch.perform()

      refute length(updated_state.dead_players) == 0

      assert Enum.member?(updated_state.active_players, manu)
      refute Enum.member?(updated_state.active_players, geralt)

      assert Enum.member?(updated_state.dead_players, geralt)
      refute Enum.member?(updated_state.dead_players, manu)
    end
  end

  defp manu(_context), do: [manu: "manu"]
  defp geralt(_context), do: [geralt: "geralt"]

  defp join(context) do
    manu_initial_position = Board.start(context.state.board())
    geralt_initial_position = Board.start(context.state.board())

    state = %{
      context.state
      | active_players: ["manu", "geralt"],
        state: %{"manu" => manu_initial_position, "geralt" => geralt_initial_position}
    }

    [state: state]
  end

  defp teleport_player_to(state, player, position) do
    Map.put(state, player, position)
  end
end
