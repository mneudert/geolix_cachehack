# Geolix Cachehack

Geolix with (hacky) cached look-ups.

## Setup

Expects `GeoLite2-City.mmdb.gz` to be available in `data` directory.

## Usage

```elixir
# uncached lookup
:timer.tc(fn -> Geolix.lookup({ 108, 168, 255, 243 }, [ where: :default ]) end)

# cached lookup
:timer.tc(fn -> Geolix.lookup({ 108, 168, 255, 243 }, [ where: :cached ]) end)
```
