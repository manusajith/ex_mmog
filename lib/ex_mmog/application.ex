defmodule ExMmog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      ExMmogWeb.Endpoint,
      ExMmogWeb.Presence,
      {ExMmog.Game, [name: ExMmog.Game]}
    ]

    opts = [strategy: :one_for_one, name: ExMmog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @spec config_change(any, any, any) :: :ok
  def config_change(changed, _new, removed) do
    ExMmogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
