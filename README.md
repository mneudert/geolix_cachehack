# Geolix Cachehack

Geolix with (hacky) cached look-ups.

## Setup

Expects `GeoLite2-City.mmdb.gz` to be available in `data` directory.

## Usage

```elixir
# regular lookup
:timer.tc(fn -> Geolix.lookup({ 108, 168, 255, 243 }) end)

# lookup without pooling (single database mode)
:timer.tc(fn -> Geolix.Database.lookup({ 108, 168, 255, 243 }, [ where: :city ]) end)
```
