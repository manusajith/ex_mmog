defmodule ExMmog.GameTest do
  use ExUnit.Case, async: true

  # doctest ExMmog.Game

  alias ExMmog.Game
  alias ExMmog.Game.State

  @cleanup_interval 500

  setup do
    game_server_name = random_id()

    pid =
      start_supervised!(Game,
        start:
          {Game, :start_link, [[name: game_server_name, cleanup_interval: @cleanup_interval]]}
      )

    :erlang.trace(pid, true, [:receive])

    [pid: pid, server: {:global, game_server_name}]
  end

  describe "view/1" do
    test "view the game state", %{server: server} do
      assert %State{} == Game.view(server)
    end

    test "handle_call(:pid, :view)", %{pid: pid, server: server} do
      Game.view(server)
      assert_receive {:trace, ^pid, :receive, {_, {_, _}, :view}}
    end
  end

  describe "join/2" do
    setup [:manu]

    test "player joins the game", %{server: server, manu: manu} do
      state = Game.join(manu, server)

      assert length(state.active_players) == 1
      assert Enum.member?(state.active_players, manu)
    end

    test "player who is already joined tries to join again", %{server: server, manu: manu} do
      state = Game.join(manu, server)
      new_state = Game.join(manu, server)

      assert new_state == state
    end

    test "handle_call(:pid, {:join, player}, _from, state)", %{
      pid: pid,
      server: server,
      manu: manu
    } do
      Game.join(manu, server)
      assert_receive {:trace, ^pid, :receive, {_, {_, _}, {:join, manu}}}
    end
  end

  describe "move/3" do
    setup [:manu]

    test "when the movement is invalid", %{server: server, manu: manu} do
      assert {:error, :bad_movement} == Game.move(manu, :nowhere, server)
    end

    test "when player who joined the game makes a valid move", %{server: server, manu: manu} do
      initial_state = Game.join(manu, server)

      case Game.move(manu, :left, server) do
        state = %{} -> assert state == Game.view(server)
        {:error, :bad_position, _} -> assert initial_state == Game.view(server)
      end
    end

    test "handle_call(:pid, {:move, player, :direction}, _from, state)", %{
      pid: pid,
      server: server,
      manu: manu
    } do
      Game.join(manu, server)
      Game.move(manu, :left, pid)
      assert_receive {:trace, ^pid, :receive, {_, {_, _}, {:move, manu, :left}}}
    end
  end

  describe "attack/2" do
    setup [:manu]

    test "when a player not in game tries to perform an attact action", %{server: server} do
      {status, reason, state} = Game.attack("geralt", server)
      assert status == :error
      assert reason == :player_not_active
      assert state == Game.view(server)
    end

    test "when a valid player performs an attack", %{server: server, manu: manu} do
      Game.join(manu, server)
      state = Game.attack(manu, server)
      assert state == Game.view(server)
    end

    test "when a valid player performs an attack which makes other players dead", %{
      pid: pid,
      server: server,
      manu: manu
    } do
      geralt = "geralt"

      Game.join(manu, server)
      Game.join("geralt", server)

      state = Game.view(server)
      assert Game.view(server) == state

      {row, col} = state.state |> Map.get(manu)

      geralt_new_position = {row + 1, col + 1}
      teleport_player_to(geralt, geralt_new_position, server)

      state = Game.attack(manu, server)
      assert state == Game.view(server)
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
    end

    test "handle_call(:pid, {:attack, player}, _from, state)", %{
      server: server,
      pid: pid,
      manu: manu
    } do
      Game.join(manu, server)
      Game.attack(manu, server)
      assert_receive {:trace, ^pid, :receive, {_, {_, _}, {:attack, manu}}}
    end
  end

  defp manu(_context), do: [manu: "manu"]

  defp random_id do
    alphabet = Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)
    Enum.take_random(alphabet, 5) |> to_string() |> String.to_atom()
  end

  defp teleport_player_to(player, position, server) do
    updated_game_state =
      :sys.get_state(server).state
      |> Map.put(player, position)

    :sys.replace_state(server, fn state -> %{state | state: updated_game_state} end)
  end
end
