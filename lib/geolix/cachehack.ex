defmodule Geolix.CacheHack do
  @moduledoc """
  Geolix CacheHack Application.
  """

  use Application

  alias Geolix.CacheHack.Cache


  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: __MODULE__.Supervisor ]
    children = [ worker(Cache, []) ]

    Supervisor.start_link(children, options)
  end
end
