defmodule ExMmog.Game do
  @moduledoc """
  Game server which holds the current game state, players and their positions.
  """

  alias __MODULE__
  alias ExMmog.Game.{Actions, State, Players}
  alias ExMmog.Game.Actions.{Join, Move, Attack, Cleanup}

  use GenServer, restart: :transient

  @timeout 60_000
  @hibernate_interval 60_000
  @cleanup_interval 10_000
  @topic inspect(__MODULE__)

  @behaviour Actions

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
  @impl true
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
  @impl true
  @spec join(binary, atom | pid | {atom, any} | {:via, atom, any}) :: any
  def join(name, pid \\ Game) when is_binary(name) do
    GenServer.call(pid, {:join, name})
  end

  @doc ~S"""
  Move a player by one step in the specified direction, where direction could be `:up`, `:down`, `:right`, `:left`

  ## Examples

      iex(10)> ExMmog.Game.move("manu", :up)
      iex(10)> ExMmog.Game.move("manu", :down)
      iex(10)> ExMmog.Game.move("manu", :left)
      iex(10)> ExMmog.Game.move("manu", :right)
  """
  @impl true
  @spec move(any, any, any) :: any
  def move(player, position, pid \\ Game)
  def move(player, :up, pid), do: GenServer.call(pid, {:move, player, :up})
  def move(player, :down, pid), do: GenServer.call(pid, {:move, player, :down})
  def move(player, :left, pid), do: GenServer.call(pid, {:move, player, :left})
  def move(player, :right, pid), do: GenServer.call(pid, {:move, player, :right})
  def move(_player, _, _pid), do: {:error, :bad_movement}

  @doc ~S"""
  Attacks other players who are in one step radius of the players position.

  When players are present in the radius of the player
  they are removed from `active_players` and moved to `dead_players` state.

  ## Examples

      iex> ExMmog.Game.attack("manu")
  """
  @impl true
  @spec attack(any, atom | pid | {atom, any} | {:via, atom, any}) :: any
  def attack(name, pid \\ Game) do
    GenServer.call(pid, {:attack, name})
  end

  @spec subscribe :: :ok | {:error, any}
  def subscribe do
    Phoenix.PubSub.subscribe(ExMmog.PubSub, @topic)
  end

  @doc false
  @impl true
  @spec init(keyword) :: {:ok, any, 60000}
  def init(args) do
    Process.flag(:trap_exit, true)

    {cleanup_interval, _opts} = Keyword.pop(args, :cleanup_interval, @cleanup_interval)
    :timer.send_interval(cleanup_interval, :cleanup)

    {state, _opts} = Keyword.pop(args, :state, %State{})
    {:ok, state, @timeout}
  end

  @doc false
  @impl true
  def handle_info(:cleanup, state) do
    case state.dead_players do
      [] ->
        {:noreply, state, @timeout}

      _ ->
        state =
          %Cleanup{state: state, inactive_players: Players.inactive(state)}
          |> Actions.Dispatch.perform()

        notify_players([:players, :updated])
        {:noreply, state, @timeout}
    end
  end

  @doc false
  @impl true
  def handle_call(:view, _from, state) do
    {:reply, state, state, @timeout}
  end

  @doc false
  @impl true
  def handle_call({:join, name}, _from, state) do
    state =
      %Join{state: state, name: name}
      |> Actions.Dispatch.perform()

    notify_players([:players, :updated])
    {:reply, state, state, @timeout}
  end

  @doc false
  @impl true
  def handle_call({:move, name, direction}, _from, state) do
    updated_state =
      %Move{state: state, name: name, direction: direction}
      |> Actions.Dispatch.perform()

    case updated_state do
      {:error, reason} ->
        {:reply, {:error, reason, state}, state, @timeout}

      _ ->
        notify_players([:players, :updated])
        {:reply, updated_state, updated_state, @timeout}
    end
  end

  @doc false
  @impl true
  def handle_call({:attack, name}, _from, state) do
    updated_state =
      %Attack{state: state, name: name}
      |> Actions.Dispatch.perform()

    case updated_state do
      {:error, reason} ->
        {:reply, {:error, reason, state}, state, @timeout}

      _ ->
        {:reply, updated_state, updated_state, @timeout}
    end
  end

  defp notify_players(event) do
    Phoenix.PubSub.broadcast(ExMmog.PubSub, @topic, {__MODULE__, event})
    {:ok, event}
  end
end
