defmodule ExMmog.Game do
  @moduledoc """
  Game server which holds the current game state, players and their positions.
  """

  alias __MODULE__
  alias ExMmog.Game.State
  alias ExMmog.Game.Actions.Join

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
    GenServer.start_link(Game, init_args, name: name, hibernate_after: @hibernate_interval)
  end

  @doc ~S"""
  View the current state of the game.

  ## Return

  - map: With status of game `%ExMmog.Game.State{}`

  ## Examples

      iex> ExMmog.Game.view
  """
  @spec view(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def view(pid \\ Game) do
    GenServer.call(pid, :view)
  end

  @doc ~S"""
  Register a player into the game.

  Takes a player name and assigns a random position in the board.


  ## Examples
      iex> GameEngine.Game.join("manu")
  """
  @spec join(binary, atom | pid | {atom, any} | {:via, atom, any}) :: any
  def join(name, pid \\ Game) when is_binary(name) do
    GenServer.call(pid, {:join, name})
  end

  @doc false
  @impl true
  @spec init(keyword) :: {:ok, any, 60000}
  def init(args) do
    Process.flag(:trap_exit, true)

    {state, _opts} = Keyword.pop(args, :state, %State{})
    {:ok, state, @timeout}
  end

  @doc false
  @impl true
  def handle_call(:view, _from, state) do
    {:reply, state, state, @timeout}
  end

  @doc false
  @impl true
  def handle_call({:join, name}, _from, state) do
    state = Join.perform(name, state)
    {:reply, state, state, @timeout}
  end
end
