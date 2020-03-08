defmodule ExMmogWeb.PageController do
  use ExMmogWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
