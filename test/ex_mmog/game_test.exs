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

  defp random_id do
    alphabet = Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)
    Enum.take_random(alphabet, 5) |> to_string() |> String.to_atom()
  end
end
