defmodule Okapi.Input do
  Enum.each [:required, :optional], fn (modifier) ->
    {doc_type, doc_an} = case modifier do
      :required -> {"required", "a"}
      :optional -> {"optional", "an"}
    end

    @doc """
    Add #{doc_an} #{doc_type} input parameter.

    Valid options:

    * `:type` - `:integer` | `:string` | ...
    * `:doc` - Additional documentation to describe the type
    """
    defmacro unquote(modifier)(name, options // [type: :any, doc: ""]) do
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
