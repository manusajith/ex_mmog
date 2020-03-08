defmodule ExMmog.GameTest do
  use ExUnit.Case, async: true

  # doctest ExMmog.Game

  alias ExMmog.Game
  alias ExMmog.Game.State

  @cleanup_interval 500

  setup do
    pid =
      start_supervised!(Game,
        start: {Game, :start_link, [[name: random_id(), cleanup_interval: @cleanup_interval]]}
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

  describe "attack/2" do
    setup [:manu]

    test "when a player not in game tries to perform an attact action", %{pid: pid} do
      {status, reason, state} = Game.attack("geralt", pid)
      assert status == :error
      assert reason == :player_not_active
      assert state == Game.view(pid)
    end

    test "when a valid player performs an attack", %{pid: pid, manu: manu} do
      Game.join(manu, pid)
      state = Game.attack(manu, pid)
      assert state == Game.view(pid)
    end

    test "when a valid player performs an attack which makes other players dead", %{
      pid: pid,
      manu: manu
    } do
      geralt = "geralt"

      Game.join(manu, pid)
      Game.join("geralt", pid)

      state = Game.view(pid)
      assert Game.view(pid) == state

      {row, col} = state.state |> Map.get(manu)

      geralt_new_position = {row + 1, col + 1}
      teleport_player_to(geralt, geralt_new_position, pid)

      state = Game.attack(manu, pid)
      assert state == Game.view(pid)
      assert Enum.member?(state.dead_players, geralt)
      refute Enum.member?(state.dead_players, manu)

      assert_received {:trace, ^pid, :receive, {_, {_, _}, {:join, manu}}}
      assert_received {:trace, ^pid, :receive, {_, {_, _}, {:join, geralt}}}
      assert_received {:trace, ^pid, :receive, {_, {_, _}, :view}}
      assert_received {:trace, ^pid, :receive, {_, {_, _}, :view}}
      assert_received {:trace, ^pid, :receive, {_, {_, _}, :get_state}}
      assert_received {:trace, ^pid, :receive, {_, {_, _}, {:replace_state, _}}}
      assert_received {:trace, ^pid, :receive, {_, {_, _}, {:attack, manu}}}
      assert_received {:trace, ^pid, :receive, {_, {_, _}, :view}}

      assert_receive {:trace, ^pid, :receive, :cleanup}, 600

      state = Game.view(pid)
      assert Enum.member?(state.active_players, geralt)
      refute Enum.member?(state.dead_players, geralt)
      refute geralt_new_position == Map.get(state.state, geralt)
    end

    test "handle_call(:pid, {:attack, player}, _from, state)", %{pid: pid, manu: manu} do
      Game.attack(manu, pid)
      assert_receive {:trace, ^pid, :receive, {_, {_, _}, {:attack, manu}}}
    end
  end

  defp manu(_context), do: [manu: "manu"]

  defp random_id do
    alphabet = Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)
    Enum.take_random(alphabet, 5) |> to_string() |> String.to_atom()
  end

  defp teleport_player_to(player, position, pid) do
    updated_game_state =
      :sys.get_state(pid).state
      |> Map.put(player, position)

    :sys.replace_state(pid, fn state -> %{state | state: updated_game_state} end)
  end
end
