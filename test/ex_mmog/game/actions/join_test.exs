defmodule ExMmog.Game.Actions.JoinTest do
  use ExUnit.Case, async: true

  alias ExMmog.Game.State
  alias ExMmog.Game.Actions.{Dispatch, Join}

  setup do
    [state: %State{}]
  end

  describe "perform/1" do
    setup [:manu]

    test "new player joins the game", %{state: state, manu: manu} do
      state =
        %Join{state: state, name: manu}
        |> Dispatch.perform()

      assert Enum.member?(state.active_players, manu)
    end

    test "existing player joins the game again", %{state: state, manu: manu} do
      initial_state =
        %Join{state: state, name: manu}
        |> Dispatch.perform()

      updated_state =
        %Join{state: initial_state, name: manu}
        |> Dispatch.perform()

      assert length(updated_state.active_players) == 1
      assert Enum.member?(updated_state.active_players, manu)
      assert initial_state == updated_state
    end
  end

  defp manu(_context), do: [manu: "manu"]
end
