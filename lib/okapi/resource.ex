defmodule Okapi.Resource do

  defmacro get(endpoint_name, path, options // []) do
    rurl = path |> String.replace("{", "<%=@") |> String.replace("}", "%>")
    template_fn = :"eex_#{endpoint_name}"

    quote do
      require EEx

      EEx.function_from_string :defp, unquote(template_fn), unquote(rurl), [:assigns]

      def unquote(endpoint_name)(params // [], headers // []) do
        handle_call(@api_module, :get, unquote(template_fn)(params), unquote(options), params, headers)
      end

      def unquote(:"#{endpoint_name}!")(params // [], headers // []) do
        {:ok, result} = handle_call(@api_module, :get, unquote(template_fn)(params), unquote(options), params, headers)
        result
      end
    end
  end

  defmacro post(endpoint_name, path, options // []) do
    rurl = path |> String.replace("{", "<%=@") |> String.replace("}", "%>")
    template_fn = :"eex_#{endpoint_name}"

    quote do
      require EEx

      EEx.function_from_string :defp, unquote(template_fn), unquote(rurl), [:assigns]

      def unquote(endpoint_name)(params // [], headers // []) do
        # IO.puts __MODULE__
        handle_call(@api_module, :post, unquote(template_fn)(params), unquote(options), params, headers)
      end
    end
  end

  def handle_call(module, method, path, options, params, headers) do
    # IO.puts module
    # IO.puts __MODULE__
    case valid_input? module, options[:input], params do
      false -> {:error, :invalid_input}
      true -> request(method, module.base_url <> path)
    end
  end

  defp request(:post, _), do: true
  defp request(:get, uri) do
    req = {to_char_list(uri), [{'Authorization', 'Bearer sk_test_BQokikJOvBiI2HlWgH4olfQ2'}]}

    case :httpc.request(:get, req, [], [body_format: :binary]) do
      {:ok, result} -> process_request_result(result)
      error -> error
    end
  end

  defp process_request_result(result) do
    {_, _, body} = result
    {:ok, decoded} = JSEX.decode(body)
    # IO.puts inspect(decoded["id"])
    {:ok, decoded}
  end

  defp valid_input?(_, nil, _), do: true
  defp valid_input?(module, input_type, input) do
    case input do
      nil -> true
      _   -> module.valid?(input_type, input)
    end
  end

end
