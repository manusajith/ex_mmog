defmodule ExMmog.Game do
  @moduledoc """
  Game server which holds the current game state, players and their positions.
  """

  alias __MODULE__
  alias ExMmog.Game.State

  use GenServer, restart: :transient

  @timeout 60_000
  @hibernate_interval 60_000


  defstruct state: %{},
            active_players: [],
            dead_players: []


  @doc ~S"""
  Starts the game server with a specified state.

  ## Examples

        iex> opts = [name: :game]
        iex> {:ok, pid} = ExMmog.Game.start_link(opts)
  """
  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    {name, init_args} = Keyword.pop(opts, :name, Game)
    GenServer.start_link(__MODULE__, init_args, name: name, hibernate_after: @hibernate_interval)
  end

  @doc false
  @impl true
  @spec init(keyword) :: {:ok, any, 60000}
  def init(args) do
    Process.flag(:trap_exit, true)

    {state, _opts} = Keyword.pop(args, :state, %State{})
    {:ok, state, @timeout}
  end
end
