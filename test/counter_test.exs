defmodule CounterTest do
  @moduledoc """
  Tests for `Gcounter.Counter`
  """

  use ExUnit.Case

  alias Gcounter.Counter

  # test "merging incoming counter states" do
  #   assert 0 == Counter.value()
  #   Counter.increment()
  #   Counter.increment()
  #   Counter.increment()
  #   assert 3 == Counter.value()
  #   inc_counter_state = %{0 => 1, 1 => 2, 2 => 2}
  #   assert %Counter{counter_states: %{0 => 3, 1 => 2, 2 => 2}} = Counter.merge(inc_counter_state)
  # end
end
