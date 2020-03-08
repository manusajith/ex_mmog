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

  @doc """
  Takes a position and returns the neighbouring cells.
  """
  @spec neighbours({any, any}, any) :: any
  def neighbours({row, col}, board \\ new().all) do
    find_neighbours(row, col, board)
  end

  @doc """
  Takes a position and checks whether the position is a valid position on the board.
  """
  def valid_position?({row, _column}, _board) when row < 0, do: {:error, :bad_position}
  def valid_position?({_row, column}, _board) when column < 0, do: {:error, :bad_position}

  def valid_position?({row, column}, board) do
    case MapSet.member?(board.walkable, {row, column}) do
      true -> {:ok, {row, column}}
      false -> {:error, :bad_position}
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

  defp find_neighbours(row, col, board) do
    Enum.reduce(0..8, [], fn direction, cells ->
      neighbours = do_find_neighbours(row, col, direction)
      [neighbours | cells]
    end)
    |> Enum.filter(&MapSet.member?(board, &1))
  end

  defp do_find_neighbours(row, col, direction) do
    n_row = row + (rem(direction, 3) - 1)
    n_col = col + (div(direction, 3) - 1)

    {n_row, n_col}
  end
end
