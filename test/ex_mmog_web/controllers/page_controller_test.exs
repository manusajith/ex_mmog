defmodule ExMmogWeb.GameControllerTest do
  use ExMmogWeb.ConnCase

  setup do
    {:ok, conn: build_conn(), name: "manu"}
  end

  test "GET /game", %{conn: conn} do
    conn = get(conn, "/game")

    player = conn.assigns.current_player
    assert redirected_to(conn) == "/game?name=#{player}"
  end

  test "GET /game?name=manu", %{conn: conn, name: name} do
    conn = get(conn, "/game?name=#{name}")

    assert conn.status == 200
  end
end
