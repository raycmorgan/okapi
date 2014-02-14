defmodule Okapi.URI do
  @doc """
  Takes a keyword list and transforms it into a query string. Nested keyword
  lists are allowed and handled via subindexing.

      Okapi.URI.encode_query(id: 1, person: [name: "Jim", age: 30])
      #=> "id=1&person[name]=Jim&person[age]=30"
  """
  def encode_query(params), do: encode_query(params, "", [])


  # Private functions

  defp encode_query([], _prefix, acc),
    do: acc |> Enum.reverse |> Enum.join("&")

  defp encode_query([{k, v} | t], prefix = "", acc) when is_list(v),
   do: encode_query(t, prefix, [encode_query(v, "#{k}", []) | acc])

  defp encode_query([{k, v} | t], prefix, acc) when is_list(v),
    do: encode_query(t, prefix, [encode_query(v, "#{prefix}[#{k}]", []) | acc])

  defp encode_query([{k, v} | t], prefix = "", acc),
    do: encode_query(t, prefix, ["#{k}=#{v}" | acc])

  defp encode_query([{k, v} | t], prefix, acc),
    do: encode_query(t, prefix, ["#{prefix}[#{k}]=#{v}" | acc])
end