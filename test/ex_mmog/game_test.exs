defmodule ExMmog.GameTest do
  use ExUnit.Case, async: true

  # doctest ExMmog.Game

  alias ExMmog.Game
  alias ExMmog.Game.State

  setup do
    pid =
      start_supervised!(Game,
        start: {Game, :start_link, [[name: random_id()]]}
      )

    :erlang.trace(pid, true, [:receive])

    [pid: pid]
  end

  describe "view/1" do
    test "view the game state", %{pid: pid} do
      assert %State{} == Game.view(pid)
    end

    test "handle_call(:pid, :view)", %{pid: pid} do
      Game.view(pid)
      assert_receive {:trace, ^pid, :receive, {_, {_, _}, :view}}
    end
  end

  describe "join/2" do
    setup [:manu]

    test "player joins the game", %{pid: pid, manu: manu} do
      state = Game.join(manu, pid)

      assert length(state.active_players) == 1
      assert Enum.member?(state.active_players, manu)
    end

    test "player who is already joined tries to join again", %{pid: pid, manu: manu} do
      state = Game.join(manu, pid)
      new_state = Game.join(manu, pid)

      assert new_state == state
    end

    test "handle_call(:pid, {:join, player}, _from, state)", %{pid: pid, manu: manu} do
      Game.join(manu, pid)
      assert_receive {:trace, ^pid, :receive, {_, {_, _}, {:join, manu}}}
    end
  end

  describe "move/3" do
    setup [:manu]

    test "when the movement is invalid", %{pid: pid, manu: manu} do
      assert {:error, :bad_movement} == Game.move(manu, :nowhere, pid)
    end

    test "when player who joined the game makes a valid move", %{pid: pid, manu: manu} do
      Game.join(manu, pid)
      assert Game.move(manu, :left, pid) == Game.view(pid)
    end

    test "handle_call(:pid, {:move, player, :direction}, _from, state)", %{pid: pid, manu: manu} do
      Game.move(manu, :left, pid)
      assert_receive {:trace, ^pid, :receive, {_, {_, _}, {:move, manu, :left}}}
    end
  end

  defp manu(_context), do: [manu: "manu"]

  defp random_id do
    alphabet = Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)
    Enum.take_random(alphabet, 5) |> to_string() |> String.to_atom()
  end
end
