defmodule Okapi do
  defmacro __using__(_) do
    quote location: :keep do
      import Okapi
      import Okapi.Input

      @before_compile Okapi

      Module.register_attribute(__MODULE__, :resources, accumulate: true)
      Module.put_attribute(__MODULE__, :inputs, [])

      def start, do: Okapi.start
      def description, do: Okapi.description(__MODULE__)
      def input_type(key), do: Okapi.get_input(__MODULE__, key)
      def valid?(key, record), do: Okapi.valid?(__MODULE__, key, record)
    end
  end

  defmacro __before_compile__(env) do
    mod = env.module
    res = Enum.reverse(Module.get_attribute(mod, :resources))
    inputs = Enum.reverse(Module.get_attribute(mod, :inputs))

    quote do
      def resources, do: unquote(res)
      def inputs, do: unquote(inputs)
    end
  end

  defmacro config(key, default // nil) do
    quote do
      def unquote(key)() do
        Okapi.get_config(unquote(__MODULE__), unquote(key), unquote(default))
      end

      def unquote(key)(value) do
        Okapi.set_config(unquote(__MODULE__), unquote(key), value)
      end
    end
  end
  
  defmacro input(key, do: block) do
    quote do
      @input_key unquote(key)
      unquote(block)
      @input_key nil
    end
  end

  defmacro resource(name, do: block) do
    parent = __CALLER__.module
    {:__aliases__, _, [module_name]} = name

    quote do
      Module.put_attribute(__MODULE__, :resources, :"#{unquote(parent)}.#{unquote(module_name)}")

      defmodule unquote(name) do
        import Okapi.Resource
        @api_module unquote(parent)

        def description, do: "Howdy"

        unquote(block)
      end
    end
  end

  def start do
    :application.ensure_started :crypto
    :application.ensure_started :asn1
    :application.ensure_started :public_key
    :application.ensure_started :ssl
    :application.ensure_started :inets
  end

  def description(module) do
    Enum.map(module.resources, &("#{&1}: #{&1.description}"))
  end

  def get_config(module, key, default // nil) do
    case :application.get_env(module, key) do
      :undefined -> default
      {:ok, value} -> value
    end
  end

  def set_config(module, key, value) do
    :application.set_env(module, key, value)
  end

  def get_input(module, key) do
    module.inputs[key]
  end

  def valid?(module, key, record) do
    schema = get_input(module, key)

    Enum.all?(schema, fn
      {_, :optional, _} -> true
      {name, :required, _} -> Enum.any?(record, &({name, _} = &1))
    end)
  end
end
