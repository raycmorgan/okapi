defmodule MyAPI do
  @moduledoc """
  A sample client library for testing purposes.
  """

  use Okapi

  config :foo
  config :api_key, "sk_test_BQokikJOvBiI2HlWgH4olfQ2"
  config :base_url, "https://api.stripe.com/v1"

  input :charge do
    required :amount, type: :integer, doc: "The amount to charge in cents."
    required :currency, type: :string, doc: "USD or EUR"

    optional :customer, type: :customer
    optional :card, type: :card
  end  

  resource Charge do
    get :retrieve, "/charges/{id}"
    post :create, "/charges", input: :charge
  end

  resource Customer do
  end

  def auth({method, uri, params, headers}) do
    headers = Okapi.add_header(headers, "Authorization", MyAPI.api_key)
    {method, uri, params, headers}
  end
end

defmodule OkapiTest do
  use ExUnit.Case

  test "start" do
    assert MyAPI.start == :ok

    # Enum.each MyAPI.Charge.__info__(:docs), fn ({{name, arity}, _, _, _, docs}) ->
    #   IO.puts "#{name}/#{arity}"

    #   if docs do
    #     IO.puts docs
    #   end

    #   IO.puts ""
    # end
  end

  test "setting and getting config" do
    assert MyAPI.foo == nil
    assert MyAPI.foo(:bar) == :ok
    assert MyAPI.foo == :bar
  end

  test "config default" do
    assert MyAPI.api_key == "sk_test_BQokikJOvBiI2HlWgH4olfQ2"
  end

  test "description" do
    assert MyAPI.description ==
      ["Elixir.MyAPI.Charge: [create: [method: :post, input: :charge], retrieve: [method: :get]]",
       "Elixir.MyAPI.Customer: []"]
  end
end

defmodule OkapiTest.Input do
  use ExUnit.Case

  test "valid input" do
    assert MyAPI.valid?(:charge, [amount: 12, currency: "USD"]) == true
  end

  test "invalid input" do
    assert MyAPI.valid?(:charge, []) == false
  end
end

defmodule OkapiTest.Resource do
  use ExUnit.Case, async: true

  setup do
    MyAPI.start
  end

  test "valid GET" do
    {:ok, result} = MyAPI.Charge.retrieve(id: "ch_103KlI2eZvKYlo2Cb03HHP8s")
    assert is_list(result) == true
  end

  test "valid GET!" do
    result = MyAPI.Charge.retrieve!(id: "ch_103KlI2eZvKYlo2Cb03HHP8s")
    assert is_list(result) == true
  end

  test "invalid GET" do
    # assert MyAPI.Charge.retrieve == {:error, :invalid_input}
  end

  test "valid POST" do
    assert MyAPI.Charge.create(amount: 12, currency: "USD") == true
  end

  test "invalid POST" do
    assert MyAPI.Charge.create == {:error, :invalid_input}
  end
end
