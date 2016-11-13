defmodule Geolix.CacheHack.Adapter do
  @moduledoc """
  Modified MMDB2 adapter with added caching.
  """

  alias Geolix.Adapter.MMDB2
  alias Geolix.CacheHack.Cache

  @behaviour Geolix.Adapter


  def database_workers() do
    import Supervisor.Spec

    [ worker(Cache, []) ]
  end

  defdelegate load_database(database), to: MMDB2

  def lookup(ip, opts) do
    case opts[:where] do
      nil   -> nil
      where -> lookup(ip, where, opts)
    end
  end


  defp lookup(ip, where, opts) do
    meta = MMDB2.Storage.Metadata.get(where)
    tree = MMDB2.Storage.Tree.get(where)

    pointer = MMDB2.LookupTree.locate(ip, tree, meta)
    result  = case Cache.load(pointer) do
      nil  ->
        data = MMDB2.Storage.Data.get(where)

        pointer
        |> lookup_pointer(data, meta.node_count)
        |> maybe_include_ip(ip)
        |> maybe_to_struct(meta.database_type, opts[:as] || :struct, opts)
        |> Cache.store(pointer)

      data -> data
    end

    result
  end

  defp lookup_pointer(0, _, _),              do: nil
  defp lookup_pointer(ptr, data, node_count) do
    offset = ptr - node_count - 16

    case MMDB2.Decoder.value(data, offset) do
      result when is_map(result) -> result
      _                          -> nil
    end
  end

  defp maybe_include_ip(nil,     _), do: nil
  defp maybe_include_ip(result, ip), do: Map.put(result, :ip_address, ip)

  defp maybe_to_struct(result,    _, :raw,       _),  do: result
  defp maybe_to_struct(result, type, :struct, opts) do
    Geolix.Result.to_struct(type, result, opts[:locale])
  end
end
