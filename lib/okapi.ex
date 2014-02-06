defmodule Okapi do
  @moduledoc """
  Provides a set of macros and patterns to describe a HTTP API client library.

      defmodule Stripe do
        use Okapi

        config :api_key

        input :charge do
          required :amount, type: :integer
        end

        resource Charge do
          get :retrieve, "/charges/{id}"
          post :create, "/charges", input: :charge
        end
      end
      
  To use the generated API client you first start it

      Stripe.start

  After that you can call the resource functions

      Stripe.Charge.retrieve id: "ch_103KlI2eZvKYlo2Cb03HHP8s"
      Stripe.Charge.create amount: 1200
  """

  alias Okapi.HTTP.Request

  defmacro __using__(_) do
    quote location: :keep do
      import Okapi
      import Okapi.Input

      @before_compile Okapi

      Module.put_attribute(__MODULE__, :inputs, [])

      def start, do: Okapi.start
      def input_type(key), do: Okapi.get_input(__MODULE__, key)
      def valid?(key, record), do: Okapi.valid?(__MODULE__, key, record)
      def auth(request), do: request

      defoverridable [auth: 1]
    end
  end

  defmacro __before_compile__(env) do
    mod = env.module
    inputs = Enum.reverse(Module.get_attribute(mod, :inputs))

    quote do
      def inputs, do: unquote(inputs)
    end
  end

  @doc """
  Add a configurable variable to the API client.

  The configuration is available when making API calls.
  """
  defmacro config(key, default \\ nil) do
    quote do
      @doc """
      Get the configuration value for `#{unquote(key)}`.

          value = #{Enum.join(Module.split(__MODULE__), ".")}.#{unquote(key)}
      """
      def unquote(key)() do
        Okapi.get_config(unquote(__MODULE__), unquote(key), unquote(default))
      end

      @doc """
      Set the configuration value for `#{unquote(key)}`.

          #{Enum.join(Module.split(__MODULE__), ".")}.#{unquote(key)}(new_value)
      """
      def unquote(key)(value) do
        Okapi.set_config(unquote(__MODULE__), unquote(key), value)
      end
    end
  end
  
  @doc """
  Creates an input validation type that can be used in a resource.

  Inside the block given to this macro, you have access to the
  macros described in `Okapi.Input`.

      defmodule Stripe do
        use Okapi

        input :charge do
          required :amount, type: integer
        end
      end
  """
  defmacro input(key, block) do
    quote do
      @input_key unquote(key)
      unquote(block)
      @input_key nil
    end
  end

  @doc """
  Creates a resource that belongs to this API client.

  Internally this will create a submodule in the current module. Inside the
  provided block, you have access to the macros found in `Okapi.Resource`.

  Most noteably you will be describing the API's endpoints here.

      defmodule Stripe do
        use Okapi

        resource Charge do
          get :retrieve, "/charges/{id}"
        end
      end
  """
  defmacro resource(name, block) do
    parent = __CALLER__.module
    {:__aliases__, _, [module_name]} = name

    quote do
      # Module.put_attribute(__MODULE__, :resources, :"#{unquote(parent)}.#{unquote(module_name)}")

      defmodule unquote(name) do
        use Okapi.Resource, api_module: unquote(parent)

        # Module.put_attribute(__MODULE__, :doc, nil)
        # Module.put_attribute(__MODULE__, :edoc, nil)

        unquote(block)
      end
    end
  end

  @doc """
  Starts all the required erlang applications.

  This includes inets, ssl and their dependencies. Before making API calls,
  this must be called.

  Note that you can also call `start` on the API module that uses Okapi as
  a convenience.
  """
  def start do
    :application.ensure_started :crypto
    :application.ensure_started :asn1
    :application.ensure_started :public_key
    :application.ensure_started :ssl
    :application.ensure_started :inets
  end

  @doc """
  Given a list of {h, v}, adds the key and value to the list.

  It will add duplicates, as multiple HTTP headers with the same key is
  allowed. This is mainly a helper to normalize awkward cased strings into
  their atom form.

  So instead of having to do:

      headers = Dict.put(headers, :"Content-Type", "application/json")

  You can do:

      headers = Okapi.add_header(headers, "Content-Type", "application/json")
  """
  def add_header(headers, key, value) when is_binary(key),
    do: add_header(headers, binary_to_atom(key), value)
  def add_header(headers, key, value) when is_atom(key),
    do: Dict.put(headers, key, value)


  # ---------------------------------------------------------------------------
  # Internal Functions
  # ---------------------------------------------------------------------------

  @doc false
  def get_config(module, key, default \\ nil) do
    case :application.get_env(module, key) do
      :undefined -> default
      {:ok, value} -> value
    end
  end

  @doc false
  def set_config(module, key, value) do
    :application.set_env(module, key, value)
  end

  @doc false
  def get_input(module, key) do
    module.inputs[key]
  end

  @doc false
  def valid?(module, key, record) do
    schema = get_input(module, key)

    Enum.all?(schema, fn
      {_, :optional, _} -> true
      {name, :required, _} -> 
        # IO.puts(inspect(record) <> "  " <> inspect(name) <> "  " <> inspect(Dict.has_key?(record, name)))
        Dict.has_key?(record, name) # Enum.any?(record, &({name, _} = &1))
    end)
  end
end
