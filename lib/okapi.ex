defmodule Okapi do
  defmacro __using__(_) do
    quote location: :keep do
      import Okapi

      @resources []

      def resources, do: @resources
      defoverridable [resources: 0]

      def validate(type, record) do
        schema = input_type(type)

        Enum.all?(schema, fn
          {_, :optional, _} -> true
          {name, :required, _} -> Enum.any?(record, &({name, _} = &1))
        end)
      end

      def description do
        Enum.map resources, &("#{&1}: " <> &1.description)
      end
    end
  end

  defmacro config(key) do
    caller = __CALLER__.module

    quote do
      def unquote(key)() do
        case :application.get_env(unquote(caller), unquote(key)) do
          :undefined -> nil
          {:ok, value} -> value
        end
      end

      def unquote(key)(value) do
        :application.set_env(unquote(caller), unquote(key), value)
      end
    end
  end
  
  defmacro input(name, do: block) do
    quote do
      def input_type(unquote(name)) do
        import Okapi.Input

        var!(description, __MODULE__) = []
        unquote(block)
        Enum.reverse var!(description, __MODULE__)
      end
    end
  end

  defmacro resource(name, do: block) do
    parent = __CALLER__.module
    {:__aliases__, _, [module_name]} = name

    quote do
      IO.puts unquote(module_name)
      @resources @resources ++ [:"#{unquote(parent)}.#{unquote(module_name)}"]

      def resources, do: @resources
      defoverridable [resources: 0]

      defmodule unquote(name) do
        import Okapi.Resource
        @parent_module unquote(parent)

        def description, do: "Howdy"

        unquote(block)
      end
    end
  end
end
