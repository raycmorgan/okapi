defmodule Okapi.Resource.Macros do
  
end

defmodule Okapi.Resource do

  defmacro get(endpoint_name, path, options // []) do
    rurl = path |> String.replace("{", "<%=@") |> String.replace("}", "%>")
    template_fn = :"eex_#{endpoint_name}"

    quote do
      require EEx

      EEx.function_from_string :defp, unquote(template_fn), unquote(rurl), [:assigns]

      def unquote(endpoint_name)(params // [], headers // []) do
        handle_call(@parent_module, :get, unquote(template_fn)(params), unquote(options), params, headers)
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
        handle_call(@parent_module, :post, unquote(template_fn)(params), unquote(options), params, headers)
      end
    end
  end

  def handle_call(module, method, path, options, params, headers) do
    valid_input? module, options[:input], params
  end

  def valid_input?(_, nil, _), do: true
  def valid_input?(module, input_type, input) do
    case input do
      nil -> true
      _   -> module.validate(input_type, input)
    end
  end

end
