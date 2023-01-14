defmodule Gcounter.Counter do
  @moduledoc """
  Counter has the in-memory grow-counter crdt and stuff related to node connections
  """
  alias Gcounter.Counter

  @type t :: %Counter{
          id: number(),
          counter_states: map()
        }

  defstruct(
    id: nil,
    counter_states: %{}
  )

  use GenServer
  require Logger

  # TODO: docs
  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # TODO: docs
  @spec increment() :: Counter.t()
  def increment() do
    GenServer.call(__MODULE__, :increment)
  end

  # TODO: docs
  @spec value() :: number()
  def value() do
    GenServer.call(__MODULE__, :value)
  end

  @spec counter_states() :: map()
  def counter_states() do
    GenServer.call(__MODULE__, :counter_states)
  end

  @impl true
  def init(opts) do
    Logger.info("Node started, #{inspect(opts)}")
    Process.send(self(), :connect_nodes, [])
    {:ok, create_init_state(opts)}
  end

  @impl true
  def handle_info(:connect_nodes, state) do
    if Node.list() |> length() < 2 do
      Logger.info("Connecting to nodes")
      other_node = Application.fetch_env!(:gcounter, :urls) |> Enum.random() |> String.to_atom()
      Node.connect(other_node)
      Process.send_after(self(), :connect_nodes, 500)
    else
      Logger.info("Connected with all nodes in the cluster #{inspect(Node.list())}")
      frequency = Enum.random(1..5)
      Logger.info("merging local counter state with a frequency #{frequency}")
      Process.send_after(self(), {:send_local_state, frequency}, frequency * 1_000)
    end
    {:noreply, state}
  end

  def handle_info({:send_local_state, frequency}, %Counter{} = state) do
    Enum.each(Node.list, fn node_name ->
      Process.send({__MODULE__, node_name}, {:merge, state.counter_states}, [])
    end)
    Process.send_after(self(), {:send_local_state, frequency}, frequency * 1_000)
    {:noreply, state}
  end

  @impl true
  def handle_info({:merge, incoming_counter_states}, %Counter{} = state) do
    incoming_counter_states
    |> Enum.reduce(state.counter_states, fn {inc_k, inc_v}, local_counter_state ->
      if inc_v > local_counter_state[inc_k] do
        Map.update!(local_counter_state, inc_k, fn _ -> inc_v end)
      else
        local_counter_state
      end
    end)
    |> then(&Map.update!(state, :counter_states, fn _ -> &1 end))
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_call(:increment, _from, %Counter{} = state) do
    state.counter_states
    |> Map.update!(state.id, fn value -> value + 1 end)
    |> then(&Map.update!(state, :counter_states, fn _ -> &1 end))
    |> then(&{:reply, &1, &1})
  end

  @impl true
  def handle_call(:value, _from, %Counter{} = state) do
    state.counter_states
    |> Enum.reduce(0, fn {_k, v}, sum ->
      sum + v
    end)
    |> then(&{:reply, &1, state})
  end

  @impl true
  def handle_call(:counter_states, _from, %Counter{} = state) do
    {:reply, state.counter_states, state}
  end

  @spec create_init_state(opts :: Keyword.t()) :: Counter.t()
  defp create_init_state(opts) do
    Counter.__struct__(
      id: Keyword.fetch!(opts, :id),
      counter_states: %{0 => 0, 1 => 0, 2 => 0}
    )
  end
end
