defmodule Stripe.Charge do
  @moduledoc """
  To charge a credit or a debit card, you create a new charge object.
  You can retrieve and refund individual charges as well as list all
  charges. Charges are identified by a unique random ID.
  """

  use Okapi.Resource, api_module: Stripe

  @doc """
  Retrieves the details of a charge previously created given a charge's
  unique ID.

      {:ok, charge} = Stripe.Charge.retrieve(id: "ch_103PJx2eZvKYlo2CRxOx5kYE")
  """
  get :retrieve, "/charges/{id}"

  @doc """
  Creates a new charge.

      {:ok, result} = Stripe.Charge.create(amount: 1200, currency: "usd")
  """
  post :create, "/charges", input: :charge
end
