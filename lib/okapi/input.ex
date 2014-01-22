defmodule Okapi.Input do
  Enum.each [:required, :optional], fn (modifier) ->
    defmacro unquote(modifier)(name, options // []) do
      modifier = unquote(modifier)

      quote do
        Okapi.Input.__input__(__MODULE__, @input_key, unquote(modifier), unquote(name), unquote(options))
      end
    end
  end

  def __input__(mod, key, type, name, options) do
    inputs = Module.get_attribute(mod, :inputs)
    input = Dict.get(inputs, key, []) ++ [Macro.escape({name, type, options})]

    Module.put_attribute(mod, :inputs, Dict.put(inputs, key, input))
  end
end
