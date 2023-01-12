defmodule Gcounter.Counter do
  @moduledoc """
  Counter has the in-memory grow-counter crdt and stuff related to node connections
  """

  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: {:global, Keyword.fetch!(opts, :name)})
  end

  @impl true
  def init(opts) do
    Logger.info("Node started, #{inspect opts}")
    Process.send(self(), :connect_nodes, [])
    {:ok, %{}}
  end


  @impl true
  def handle_info(:connect_nodes, state) do
    if Node.list() |> length() < 2 do
      Logger.info("Connecting to nodes")
      other_node = Application.fetch_env!(:gcounter, :urls) |> Enum.random() |> String.to_atom()
      Node.connect(other_node)
      Process.send_after(self(), :connect_nodes, 500)
    else
      Logger.info("Connected with all nodes in the cluster #{inspect Node.list}")
    end
    {:noreply, state}
  end

end
