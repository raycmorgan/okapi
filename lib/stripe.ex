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

  def auth(request) do
    Okapi.add_header(request.headers, "Authorization", "Bearer #{Stripe.api_key}")
      |> request.headers
  end
end
