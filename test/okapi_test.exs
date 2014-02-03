defmodule OkapiTest do
  use ExUnit.Case
  alias OkapiTest.Stripe

  test "start" do
    assert Stripe.start == :ok
  end

  test "setting and getting config" do
    assert Stripe.foo == nil
    assert Stripe.foo(:bar) == :ok
    assert Stripe.foo == :bar
  end

  test "config default" do
    assert Stripe.api_key == "sk_XPymrxOPupS9EZasz3Aso04w4KAM4"
  end
end

defmodule OkapiTest.Input do
  use ExUnit.Case
  alias OkapiTest.Stripe

  test "valid input" do
    assert Stripe.valid?(:charge, [amount: 12, currency: "USD"]) == true
  end

  test "invalid input" do
    assert Stripe.valid?(:charge, []) == false
  end
end
