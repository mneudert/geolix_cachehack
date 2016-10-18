defmodule Geolix.CacheHack.Mixfile do
  use Mix.Project

  def project do
    [ app:     :geolix_cachehack,
      version: "0.1.0",
      elixir:  "~> 1.2",

      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,

      deps: deps() ]
  end

  def application do
    [ applications: [ :geolix ],
      mod:          { Geolix.CacheHack, [] } ]
  end

  defp deps do
    [{ :geolix, github: "mneudert/geolix", tag: "1c16367" }]
  end
end
