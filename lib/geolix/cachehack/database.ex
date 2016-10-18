defmodule Geolix.CacheHack.Database do
  @moduledoc """
  Geolix.Database module with added caching.

  Modified to work with just one database registered as `:city`.
  """

  use Bitwise, only_operators: true

  require Logger

  alias Geolix.Adapter.MMDB2.Storage
  alias Geolix.Adapter.MMDB2.Decoder
  alias Geolix.CacheHack.Cache
  alias Geolix.Result


  def lookup(ip) do
    meta = Storage.Metadata.get(:city)
    tree = Storage.Tree.get(:city)

    pointer = parse_lookup_tree(ip, tree, meta)
    result  = case Cache.load(pointer) do
      nil  ->
        data = Storage.Data.get(:city)

        pointer
        |> lookup_pointer(data, meta.node_count)
        |> maybe_include_ip(ip)
        |> maybe_to_struct(meta.database_type, :struct, [])
        |> Cache.store(pointer)

      data -> data
    end

    result
  end

  defp lookup_pointer(0, _, _),              do: nil
  defp lookup_pointer(ptr, data, node_count) do
    offset = ptr - node_count - 16

    case Decoder.value(data, offset) do
      result when is_map(result) -> result
      _                          -> nil
    end
  end

  defp maybe_include_ip(nil,     _), do: nil
  defp maybe_include_ip(result, ip), do: Map.put(result, :ip_address, ip)

  defp maybe_to_struct(result,    _, :raw,       _),  do: result
  defp maybe_to_struct(result, type, :struct, opts) do
    Result.to_struct(type, result, opts[:locale])
  end


  defp parse_lookup_tree({ 0, 0, 0, 0, 0, 65535, a, b }, tree, meta) do
    { a >>> 8, a &&& 0x00FF, b >>> 8, b &&& 0x00FF }
    |> parse_lookup_tree(tree, meta)
  end

  defp parse_lookup_tree({ a, b, c, d }, tree, %{ ip_version: 6 } = meta) do
    << a :: size(8), b :: size(8), c :: size(8), d :: size(8) >>
    |> parse_lookup_tree_bitwise(0, 32, 96, tree, meta)
  end
  defp parse_lookup_tree({ a, b, c, d }, tree, meta) do
    << a :: size(8), b :: size(8), c :: size(8), d :: size(8) >>
    |> parse_lookup_tree_bitwise(0, 32, 0, tree, meta)
  end

  defp parse_lookup_tree({ _, _, _, _, _, _, _, _ }, _, %{ ip_version: 4 }) do
    0
  end

  defp parse_lookup_tree({ a, b, c, d, e, f, g, h }, tree, meta) do
    << a :: size(16), b :: size(16), c :: size(16), d :: size(16),
       e :: size(16), f :: size(16), g :: size(16), h :: size(16) >>
    |> parse_lookup_tree_bitwise(0, 128, 0, tree, meta)
  end


  defp parse_lookup_tree_bitwise(path, bit, bit_count, node, tree, meta)
      when bit < bit_count
  do
    if node >= meta.node_count do
      parse_lookup_tree_bitwise(nil, nil, nil, node, nil, meta)
    else
      rest_size = bit_count - bit - 1

      << _ :: size(bit), node_bit :: size(1), _ :: size(rest_size) >> = path

      node = read_node(node, node_bit, tree, meta)

      parse_lookup_tree_bitwise(path, bit + 1, bit_count, node, tree, meta)
    end
  end

  defp parse_lookup_tree_bitwise(_, _, _, node, _, meta) do
    node_count = meta.node_count

    cond do
      node >  node_count -> node
      node == node_count -> 0
      true ->
        Logger.error "Invalid node below node_count: #{node}"
        0
    end
  end


  defp read_node(node, index, tree, meta) do
    record_size = meta.record_size
    record_half = rem(record_size, 8)
    record_left = record_size - record_half

    node_start = div(node * record_size, 4)
    node_len   = div(record_size, 4)
    node_part  = binary_part(tree, node_start, node_len)

    << low   :: size(record_left),
       high  :: size(record_half),
       right :: size(record_size) >> = node_part

    case index do
      0 -> low + (high <<< record_left)
      1 -> right
    end
  end
end
