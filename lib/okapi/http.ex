defmodule Okapi.HTTP do
  defrecord Request,
    method: nil,
    path: nil,
    params: nil,
    headers: nil,
    api_module: nil
end