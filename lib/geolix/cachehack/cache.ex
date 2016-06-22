defmodule Geolix.CacheHack.Cache do
  @moduledoc """
  Geolix CacheHacke Caching Agent.
  """

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def load(id), do: Agent.get(__MODULE__, &Map.get(&1, id, nil))

  def store(data, id) do
    Agent.update(__MODULE__, &Map.put(&1, id, data))
    data
  end
end
