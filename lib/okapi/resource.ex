defmodule Okapi.Resource do
  @moduledoc """
  Provides the functions to create the endpoint resources and also perform
  the actual HTTP(s) API calls.
  """

  defexception NotFound, [:code, :type, :message]
  defexception BadRequest, [:code, :type, :message]
  defexception RequestError, [:code, :type, :message]

  alias Okapi.HTTP.Request

  defmacro __using__(opts) do
    quote location: :keep do
      import Okapi.Resource

      @before_compile Okapi.Resource
      @api_module unquote(opts)[:api_module]

      Module.register_attribute(__MODULE__, :endpoints, accumulate: true)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def description, do: inspect(@endpoints)
    end
  end

  Enum.each [:get, :post], fn (method) ->
    {doc_fn_name, doc_out_name} = case method do
      :get -> {"retrieve", "charge"}
      :post -> {"create", "result"}
    end

    @doc """
    Creates an endpoint function that uses the
    #{String.upcase(to_string(method))} HTTP verb.

    The function that will be generated will be named `endpoint_name`. For
    example, given the following module.

        defmodule Stripe do
          use Okapi

          resource Charge do
            #{method} :#{doc_fn_name}, "/charges/{id}"
          end
        end

    The function `#{doc_fn_name}` will be added to the Stripe.Charge module.

        {:ok, #{doc_out_name}} = Stripe.Charge.#{doc_fn_name}(id: "ch_103KlI2eZvKYlo2Cb03HHP8s")

    There will also be a ! version created that simply returns the result, but
    throws an error on failed requests.

        #{doc_out_name} = Stripe.Charge.#{doc_fn_name}!(id: "ch_103KlI2eZvKYlo2Cb03HHP8s")
    """
    defmacro unquote(method)(endpoint_name, path, options // []) do
      tmpl_input = if String.contains?(path, "{"), do: [:assigns], else: [:"_assigns"]

      rurl = path |> String.replace("{", "<%=@") |> String.replace("}", "%>")
      template_fn = :"eex_#{endpoint_name}"
      method = unquote(method)

      quote do
        def unquote(endpoint_name)(params // [], headers // []) do
          uri = unquote(template_fn)(params)
          case handle_call(@api_module, unquote(method), uri, unquote(options), params, headers) do
            {:ok, {status_code, _, _}} = result when status_code >= 200 and status_code < 300 -> result
            {:ok, result} -> {:error, result}
          end
        end

        @doc "See `#{unquote(endpoint_name)}/2`. Throws exception if call fails."
        def unquote(:"#{endpoint_name}!")(params // [], headers // []) do
          uri = unquote(template_fn)(params)

          case handle_call(@api_module, unquote(method), uri, unquote(options), params, headers) do
            {:ok, {status_code, _, result}} when status_code >= 200 and status_code < 300 -> result
            {:ok, {status_code, headers, result}} ->
              type = result["error"]["type"]
              message = result["error"]["message"]

              raise (case status_code do
                400 -> BadRequest[code: status_code, message: message, type: type]
                404 -> NotFound[code: status_code, message: message, type: type]
                _   -> RequestError[code: status_code, message: message, type: type]
              end)
            error -> raise error
          end
        end

        Module.put_attribute(__MODULE__, :endpoints, 
          { unquote(endpoint_name),
            Dict.merge([method: unquote(method)], unquote(options)) })

        require EEx
        EEx.function_from_string :defp, unquote(template_fn), unquote(rurl), unquote(tmpl_input)
      end
    end
  end

  @doc false
  def handle_call(module, method, path, options, params, headers) do
    request = Request.new(method: method, path: path, params: params, headers: headers, api_module: module)
    request = before_request(request)

    if valid_input?(module, options[:input], params) do
      perform_request(request, module) |> process_request_result
    else
      {:error, :invalid_input}
    end
  end

  defp before_request(request) do
    request.api_module.auth(request)
  end

  defp perform_request(request=Request[method: :post], module) do
    headers = dict_to_headers(request.headers)

    uri = to_char_list(module.base_url <> request.path)
    req = {uri, headers, 'application/x-www-form-urlencoded', URI.encode_query(request.params)}

    :httpc.request(request.method, req, [], [body_format: :binary])
  end

  defp perform_request(request=Request[method: :get], module) do
    headers = dict_to_headers(request.headers)

    uri = to_char_list(module.base_url <> request.path)
    req = {uri, headers}

    :httpc.request(request.method, req, [], [body_format: :binary])
  end

  defp process_request_result({:ok, {{_, status_code, _}, headers, body}}) do
    {:ok, {status_code, headers, JSEX.decode!(body)}}
  end
  defp process_request_result(error), do: error

  defp valid_input?(_, nil, _), do: true
  defp valid_input?(_, _, nil), do: true
  defp valid_input?(module, input_type, input), do: Okapi.valid?(module, input_type, input)

  defp dict_to_headers(dict) do
    Enum.map dict, fn ({k, v}) ->
      {to_char_list(k), to_char_list(v)}
    end
  end
end
