defmodule Gcounter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias Gcounter.Counter

  @impl true
  def start(_type, _args) do
    children = [
      {Counter,
       [
         name: Application.fetch_env!(:gcounter, :type),
         id: Application.fetch_env!(:gcounter, :id)
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gcounter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
