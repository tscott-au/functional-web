defmodule IslandsEngine.FakeStore do
  @behaviour IslandsEngine.Store

  @impl true
  def save(_store, _record) do
    []
  end

  @impl true
  def read(_store, _key) do
    []
  end
end
