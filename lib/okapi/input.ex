defmodule Okapi.Input do
  defmacro required(name, options // []) do
    quote do
      Okapi.Input.__input__(__MODULE__, @input_key, :required, unquote(name), unquote(options))
    end
  end

  defmacro optional(name, options // []) do
    quote do
      Okapi.Input.__input__(__MODULE__, @input_key, :optional, unquote(name), unquote(options))
    end
  end

  def __input__(mod, key, type, name, options) do
    inputs = Module.get_attribute(mod, :inputs)
    input = Dict.get(inputs, key, []) ++ [Macro.escape({name, type, options})]

    Module.put_attribute(mod, :inputs, Dict.put(inputs, key, input))
  end
end
