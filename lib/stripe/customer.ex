defmodule Stripe.Customer do
  @moduledoc """
  Customer objects allow you to perform recurring charges and track multiple
  charges that are associated with the same customer. The API allows you to
  create, delete, and update your customers. You can retrieve individual
  customers as well as a list of all your customers.
  """

  use Okapi.Resource, api_module: Stripe

  @doc "Retrieves the details of a customer by the customer's unique ID."
  get :retrieve, "/customers/{id}"
end
