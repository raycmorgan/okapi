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
    @doc """
    Blah Blah Blah
    """
    get :retrieve, "/charges/{id}"
    post :create, "/charges", input: :charge
  end

  resource Customer do
    @moduledoc """
    This is a test.
    """
  end

  def auth({method, uri, params, headers}) do
    headers = Okapi.add_header(headers, "Authorization", MyAPI.api_key)
    {method, uri, params, headers}
  end
end