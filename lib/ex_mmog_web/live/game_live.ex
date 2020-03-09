defmodule ExMmogWeb.GameLive do
  @moduledoc """
  Live view of Game.
  """
  use Phoenix.LiveView

  alias ExMmog.Game
  alias ExMmogWeb.Presence

  @topic inspect(Game)

  @doc false
  @impl true
  @spec render(any) :: any
  def render(assigns) do
    ExMmogWeb.GameView.render("index.html", assigns)
  end

  @doc false
  @impl true
  @spec mount(any, map, Phoenix.LiveView.Socket.t()) :: {:ok, any}
  def mount(
        _params,
        %{"player_name" => player_name, "game_server_pid" => game_server_pid},
        socket
      ) do
    Game.subscribe()
    {:ok, _} = Presence.track(self(), @topic, player_name, %{player_name: player_name})

    {:ok,
     assign(socket,
       game_server_pid: game_server_pid,
       player_name: player_name,
       state: GenServer.call({:global, game_server_pid}, :view)
     )}
  end

  @doc false
  @impl true
  @spec handle_event(<<_::32, _::_*16>>, any, Phoenix.LiveView.Socket.t()) :: {:noreply, any}
  def handle_event("move", %{"value" => direction}, socket) do
    player = socket.assigns.player_name
    direction = String.to_atom(direction)
    do_handle_event(socket, {:move, player, direction})
  end

  def handle_event("attack", _value, socket) do
    player = socket.assigns.player_name
    do_handle_event(socket, {:attack, player})
  end

  @doc false
  @impl true
  @spec handle_info(any, any) :: {:noreply, any}
  def handle_info({Game, [:players, :updated]}, socket) do
    {:noreply,
     assign(socket,
       state: game_state(socket)
     )}
  end

  @doc false
  @impl true
  def handle_info(_event, socket) do
    {:noreply, socket}
  end

  defp do_handle_event(socket, action) do
    game_server_pid = game_server(socket)
    GenServer.call({:global, game_server_pid}, action)

    {:noreply,
     assign(socket,
       state: game_state(socket)
     )}
  end

  defp game_server(socket) do
    socket.assigns.game_server_pid
  end

  defp game_state(socket) do
    game_server_pid = socket |> game_server()

    GenServer.call({:global, game_server_pid}, :view)
  end
end
