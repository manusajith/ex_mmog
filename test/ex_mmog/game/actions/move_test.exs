defmodule ExMmog.Game.Actions.MoveTest do
  use ExUnit.Case, async: true

  alias ExMmog.Board
  alias ExMmog.Game.State
  alias ExMmog.Game.Actions.{Dispatch, Move}

  setup do
    state = %State{}
    [state: state]
  end

  describe "perform/1" do
    setup [:manu, :join]

    test "player moves towards the right", %{state: state, manu: manu} do
      updated_state =
        %Move{state: state, name: manu, direction: :right}
        |> Dispatch.perform()

      case updated_state do
        {:error, reason} ->
          assert reason == :bad_position

        updated_state = %State{} ->
          {initial_row, initial_col} = Map.get(state.state, manu)
          {new_row, new_col} = Map.get(updated_state.state, manu)
          assert {new_row, new_col} == {initial_row, initial_col + 1}
      end
    end

    test "player moves towards the left", %{state: state, manu: manu} do
      updated_state =
        %Move{state: state, name: manu, direction: :left}
        |> Dispatch.perform()

      case updated_state do
        {:error, reason} ->
          assert reason == :bad_position

        updated_state = %State{} ->
          {initial_row, initial_col} = Map.get(state.state, manu)
          {new_row, new_col} = Map.get(updated_state.state, manu)
          assert {new_row, new_col} == {initial_row, initial_col - 1}
      end
    end

    test "player moves towards up", %{state: state, manu: manu} do
      updated_state =
        %Move{state: state, name: manu, direction: :up}
        |> Dispatch.perform()

      case updated_state do
        {:error, reason} ->
          assert reason == :bad_position

        updated_state = %State{} ->
          {initial_row, initial_col} = Map.get(state.state, manu)
          {new_row, new_col} = Map.get(updated_state.state, manu)
          assert {new_row, new_col} == {initial_row - 1, initial_col}
      end
    end

    test "player moves towards down", %{state: state, manu: manu} do
      updated_state =
        %Move{state: state, name: manu, direction: :down}
        |> Dispatch.perform()

      case updated_state do
        {:error, reason} ->
          assert reason == :bad_position

        updated_state = %State{} ->
          {initial_row, initial_col} = Map.get(state.state, manu)
          {new_row, new_col} = Map.get(updated_state.state, manu)
          assert {new_row, new_col} == {initial_row + 1, initial_col}
      end
    end
  end

  defp manu(_context), do: [manu: "manu"]

  defp join(context) do
    initial_position = Board.start(context.state.board())
    state = %{context.state | active_players: ["manu"], state: %{"manu" => initial_position}}
    [state: state]
  end
end
