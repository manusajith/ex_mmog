defmodule ExMmog.Server do
  @moduledoc """
  Server which synchronizes all the players state and writes into an ets table.
  """
  use GenServer, restart: :transient

  alias ExMmog.Game.State

  @topic inspect(ExMmog.Game)

  @spec start_link(keyword) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    {name, init_args} = Keyword.pop(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, init_args, name: {:global, name})
  end

  @doc false
  @impl true
  @spec init(keyword) :: {:ok, any}
  def init(args) do
    {state, _opts} = Keyword.pop(args, :state, %State{})
    {table_name, _opts} = Keyword.pop(args, :table_name, :game_state)

    :ets.new(table_name, [:set, :public, :named_table])
    :ets.insert(table_name, {:state, state})

    {:ok, state}
  end

  @doc """
  Synchronise the state from player, updates the global state, and broadcasts to all players.
  """
  @impl true
  def handle_cast({:synchronize, state}, _state) do
    {:state, current_state} = :ets.lookup(:game_state, :state) |> List.first()
    state = Map.merge(current_state, state)

    :ets.insert(:game_state, {:state, state})

    DynamicSupervisor.which_children(ExMmog.Game.Supervisor)
    |> Enum.map(fn {_, pid, _, _} -> GenServer.cast(pid, :synchronized) end)

    Phoenix.PubSub.broadcast(ExMmog.PubSub, @topic, {ExMmog.Game, [:players, :updated]})
    {:noreply, state}
  end
end
