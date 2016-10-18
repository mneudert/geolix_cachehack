use Mix.Config

path_city =
     [ __DIR__, "../data/GeoLite2-City.mmdb.gz" ]
  |> Path.join()
  |> Path.expand()

config :geolix,
  pool:      [ size: 5, max_overflow: 10 ],
  databases: [
    %{
      id:      :city,
      adapter: Geolix.Adapter.MMDB2,
      source:  path_city
    }
  ]
