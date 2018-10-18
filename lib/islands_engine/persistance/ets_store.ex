defmodule IslandsEngine.ETSStore do
  @behaviour IslandsEngine.Store

  @impl true
  def save(store, record) do
    :ets.insert(store, record)
  end

  @impl true
  def read(store, key) do
    :ets.lookup(store, key)
  end
end
