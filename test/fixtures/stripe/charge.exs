defmodule OkapiTest.Stripe.Charge do
  use Okapi.Resource, api_module: OkapiTest.Stripe

  @prefix "/charges"

  @doc """
  Blah Blah Blah
  """
  get :retrieve, "/{id}"
  post :create
end