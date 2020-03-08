defmodule ExMmog.Game.State do
  @moduledoc """
  Game state module which holds the current game state, players and their positions.
  """

  alias __MODULE__
  alias ExMmog.Board

  defstruct board: Board.new,
            state: %{},
            active_players: [],
            dead_players: []

  @type t :: %State{
          board: Board.t(),
          state: Map.t(),
          active_players: List.t(),
          dead_players: List.t()
        }
end
