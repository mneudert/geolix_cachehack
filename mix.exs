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
    [ applications: [ :geolix ]]
  end

  defp deps do
    [{ :geolix, "0.10.1" }]
  end
end