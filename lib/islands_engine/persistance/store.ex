defmodule IslandsEngine.Store do
  @callback save(atom(), term()) :: {:ok} | {:error, any()}
  @callback read(atom(), atom()) :: [{any(), any()}]
end
