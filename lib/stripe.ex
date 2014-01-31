defmodule Stripe do
  @moduledoc """
  A sample client library for testing purposes.
  """

  use Okapi

  config :api_key, "sk_test_BQokikJOvBiI2HlWgH4olfQ2"
  config :base_url, "https://api.stripe.com/v1"

  input :charge do
    required :amount, type: :integer, doc: "The amount to charge in cents."
    required :currency, type: :string, doc: "USD or EUR"

    optional :customer, type: :customer
    optional :card, type: :card
  end

  resource Charge do
    @moduledoc """
    To charge a credit or a debit card, you create a new charge object.
    You can retrieve and refund individual charges as well as list all
    charges. Charges are identified by a unique random ID.
    """

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

  resource Customer do
    @moduledoc """
    Customer objects allow you to perform recurring charges and track multiple
    charges that are associated with the same customer. The API allows you to
    create, delete, and update your customers. You can retrieve individual
    customers as well as a list of all your customers.
    """
  end

  def auth({method, uri, params, headers}) do
    headers = Okapi.add_header(headers, "Authorization", "Bearer #{Stripe.api_key}")
    {method, uri, params, headers}
  end
end