defmodule ExMmogWeb.GameController do
  use ExMmogWeb, :controller

  alias ExMmog.Game

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, %{"name" => name}) do
    server_name = ("game_server_" <> name) |> String.to_atom()

    case DynamicSupervisor.start_child(ExMmog.Game.Supervisor, {Game, [name: server_name]}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end

    GenServer.call({:global, server_name}, {:join, name})
    session = %{"game_server_pid" => server_name, "player_name" => name}

    conn
    |> live_render(ExMmogWeb.GameLive, session: session)
  end

  def index(conn, _) do
    random_name = random_name()

    conn
    |> assign(:current_player, random_name)
    |> redirect(to: Routes.game_path(conn, :index, name: random_name))
  end

  defp random_name do
    alphabet = Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9)
    Enum.take_random(alphabet, 5) |> to_string() |> String.to_atom()
  end
end
