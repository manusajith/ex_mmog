defmodule ExMmog.Game.Actions.CleanupTest do
  use ExUnit.Case, async: true

  alias ExMmog.Board
  alias ExMmog.Game.State
  alias ExMmog.Game.Actions.{Dispatch, Cleanup}

  setup do
    state = %State{}
    [state: state]
  end

  describe "perform/1" do
    setup [:manu, :geralt, :ciri, :join]

    test "performs a cleanup of dead players", %{
      state: state,
      manu: manu,
      geralt: geralt,
      ciri: ciri
    } do
      assert Enum.member?(state.active_players, manu)
      assert Enum.member?(state.dead_players, geralt)
      assert Enum.member?(state.dead_players, ciri)

      inactive_players = [ciri]

      manu_position = Map.get(state.state, manu)
      geralt_position = Map.get(state.state, geralt)

      updated_state =
        %Cleanup{state: state, inactive_players: inactive_players}
        |> Dispatch.perform()

      assert length(updated_state.dead_players) == 0

      assert Enum.member?(updated_state.active_players, manu)
      refute Enum.member?(updated_state.dead_players, manu)
      assert manu_position == Map.get(updated_state.state, manu)

      assert Enum.member?(updated_state.active_players, geralt)
      refute Enum.member?(updated_state.dead_players, geralt)
      refute geralt_position == Map.get(updated_state.state, geralt)

      refute Enum.member?(updated_state.active_players, ciri)
      refute Enum.member?(updated_state.dead_players, ciri)
      assert nil == Map.get(updated_state.state, ciri)
    end
  end

  defp manu(_context), do: [manu: "manu"]
  defp geralt(_context), do: [geralt: "geralt"]
  defp ciri(_context), do: [ciri: "ciri"]

  defp join(context) do
    manu_initial_position = Board.start(context.state.board())
    geralt_initial_position = Board.start(context.state.board())
    ciri_initial_position = Board.start(context.state.board())

    state = %{
      context.state
      | active_players: ["manu"],
        dead_players: ["geralt", "ciri"],
        state: %{
          "manu" => manu_initial_position,
          "geralt" => geralt_initial_position,
          "ciri" => ciri_initial_position
        }
    }

    [state: state]
  end
end
