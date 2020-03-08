defmodule ExMmog.Board do
  @moduledoc """
  Module for rendering the Game board.
  """

  alias __MODULE__

  defstruct all: [], walls: [], walkable: []

  @type t :: %Board{
          all: MapSet.t(),
          walls: MapSet.t(),
          walkable: MapSet.t()
        }

  @doc """
  Takes the board row size and col size and returns a grid containing walls at random positions.
  """
  @spec new(any, any) :: ExMmog.Board.t()
  def new(row_size \\ 20, col_size \\ 20) do
    with all <- build_grid(row_size, col_size), walls <- build_walls(all) do
      %Board{all: all, walls: walls, walkable: MapSet.difference(all, walls)}
    end
  end

  defp build_grid(row_size, col_size) do
    for col <- 0..col_size,
        row <- 0..row_size,
        into: MapSet.new(),
        do: {col, row}
  end

  defp build_walls(grid) do
    grid
    |> Enum.shuffle()
    |> Enum.take(10)
    |> MapSet.new()
  end
end
