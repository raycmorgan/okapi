defmodule Okapi.URI do
  def encode_query(params), do: encode_query(params, "", [])

  defp encode_query([], _prefix, acc), do: acc |> Enum.reverse |> Enum.join("&")

  defp encode_query([{k, v} | t], "", acc) when is_list(v) do
    encode_query(t, "", [encode_query(v, "#{k}", []) | acc])
  end  

  defp encode_query([{k, v} | t], prefix, acc) when is_list(v) do
    encode_query(t, prefix, [encode_query(v, "#{prefix}[#{k}]", []) | acc])
  end

  defp encode_query([{k, v} | t], "", acc) do
    encode_query(t, "", ["#{k}=#{v}" | acc])
  end

  defp encode_query([{k, v} | t], prefix, acc) do
    encode_query(t, prefix, ["#{prefix}[#{k}]=#{v}" | acc])
  end
end