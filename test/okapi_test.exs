defmodule MyAPI do
  use Okapi

  config :foo

  input :charge do
    required :amount, type: :integer, doc: "The amount to charge in cents."
    required :currency, type: :string, doc: "USD or EUR"

    optional :customer, type: :customer
    optional :card, type: :card
  end  

  resource Charge do
    # doc doc_url("customers")
    get :retrieve, "/charges/{id}"
    post :create, "/charges", input: :charge
  end

  resource Customer do
  end
end

defmodule OkapiTest do
  use ExUnit.Case

  test "setting and getting config" do
    assert MyAPI.foo == nil
    assert MyAPI.foo(:bar) == :ok
    assert MyAPI.foo == :bar

    IO.puts inspect(MyAPI.description)
  end
end

defmodule OkapiTest.Input do
  use ExUnit.Case

  test "input" do
    assert true == MyAPI.validate(:charge, [amount: 12])
  end
end

defmodule OkapiTest.Resource do
  use ExUnit.Case

  test "resource" do
    assert MyAPI.Charge.retrieve(id: 12) == "GET /charges/12"
    
    assert MyAPI.Charge.create == false
    assert MyAPI.Charge.create(amount: 12, currency: "USD") == true
  end
end
