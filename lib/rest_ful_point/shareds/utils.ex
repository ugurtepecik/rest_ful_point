defmodule Utils do
  @moduledoc false

  @spec convert_to_keyword_list(map :: map()) :: list(keyword())
  def convert_to_keyword_list(map) when is_map(map) do
    Enum.map(map, fn {key, value} -> {String.to_existing_atom(key), value} end)
  end
end
