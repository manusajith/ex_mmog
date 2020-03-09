defmodule ExMmog.Game.Players do
  @moduledoc """
  Returns a list of active playing users using Presence.
  """

  @topic inspect(ExMmog.Game)

  alias ExMmogWeb.Presence

  @doc """
  Returns a list of inactive players.
  """
  @spec inactive(atom | %{active_players: [any], dead_players: [any]}) :: [any]
  def inactive(state) do
    (state.active_players ++ state.dead_players) -- active()
  end

  defp active do
    Presence.list(@topic)
    |> Enum.map(fn {_player_name, data} ->
      data[:metas]
      |> List.first()
      |> Map.get(:player_name)
    end)
  end
end
