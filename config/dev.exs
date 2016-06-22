use Mix.Config

path_city =
     [ __DIR__, "../data/GeoLite2-City.mmdb.gz" ]
  |> Path.join()
  |> Path.expand()

config :geolix,
  databases: [ city: path_city ],
  pool:      [ size: 5, max_overflow: 10 ]
