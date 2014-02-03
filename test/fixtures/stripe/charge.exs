defmodule OkapiTest.Stripe.Charge do
  use Okapi.Resource, api_module: OkapiTest.Stripe

  @doc """
  Blah Blah Blah
  """
  get :retrieve, "/charges/{id}"
  post :create, "/charges"
end