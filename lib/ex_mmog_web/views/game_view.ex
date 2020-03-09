defmodule ExMmogWeb.GameView do
  use ExMmogWeb, :view

  def is_wall?(assigns, position) do
    position in assigns.state.board.walls
  end

  def players_at(assigns, current_position) do
    assigns.state.state
    |> Enum.reduce([], fn {name, position}, players ->
      case position == current_position do
        true -> [name | players]
        false -> players
      end
    end)
    |> format_multiplayer
  end

  defp format_multiplayer(players) do
    case length(players) > 1 do
      true -> Enum.join(players, ", ")
      false -> players
    end
  end
end
