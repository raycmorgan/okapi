defmodule Okapi.Input do
  defmacro required(name, options // []) do
    quote do
      attribute = {unquote(name), :required, unquote(options)}
      var!(description, __MODULE__) = [attribute | var!(description, __MODULE__)]
    end
  end

  defmacro optional(name, options // []) do
    quote do
      attribute = {unquote(name), :optional, unquote(options)}
      var!(description, __MODULE__) = [attribute | var!(description, __MODULE__)]
    end
  end
end
