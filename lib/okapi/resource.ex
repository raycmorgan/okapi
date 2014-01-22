defmodule Okapi.Resource do

  defmacro __using__(opts) do
    quote location: :keep do
      import Okapi.Resource

      @before_compile Okapi.Resource
      @api_module unquote(opts)[:api_module]

      Module.register_attribute(__MODULE__, :endpoints, accumulate: true)
    end
  end

  defmacro __before_compile__(env) do
    quote do
      def description, do: inspect(@endpoints)
    end
  end

  Enum.each [:get, :post], fn (method) ->
    defmacro unquote(method)(endpoint_name, path, options // []) do
      rurl = path |> String.replace("{", "<%=@") |> String.replace("}", "%>")
      template_fn = :"eex_#{endpoint_name}"
      method = unquote(method)

      quote do
        require EEx
        EEx.function_from_string :defp, unquote(template_fn), unquote(rurl), [:assigns]

        Module.put_attribute(__MODULE__, :endpoints, 
          { unquote(endpoint_name),
            Dict.merge([method: unquote(method)], unquote(options)) })

        def unquote(endpoint_name)(params // [], headers // []) do
          handle_call(@api_module, unquote(method), unquote(template_fn)(params), unquote(options), params, headers)
        end

        def unquote(:"#{endpoint_name}!")(params // [], headers // []) do
          {:ok, result} = handle_call(@api_module, unquote(method), unquote(template_fn)(params), unquote(options), params, headers)
          result
        end
      end
    end
  end

  def handle_call(module, method, path, options, params, headers) do
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

  defp process_request_result({_, _, body}), do: JSEX.decode(body)

  defp valid_input?(_, nil, _), do: true
  defp valid_input?(_, _, nil), do: true
  defp valid_input?(module, input_type, input), do: Okapi.valid?(module, input_type, input)

end
