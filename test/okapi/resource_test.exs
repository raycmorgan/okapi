defmodule OkapiTest.Resource do
  use ExUnit.Case, async: true
  alias OkapiTest.Stripe

  setup do
    Stripe.start
  end

  test "valid GET" do
    {:ok, {status_code, headers, charge}} = Stripe.Charge.retrieve(id: "ch_1tEa2FtVyao2Yb")
    
    assert status_code == 200
    assert is_list(headers) == true
    assert charge["id"] == "ch_1tEa2FtVyao2Yb"
  end

  test "valid GET!" do
    # {status_code, headers, charge} = Stripe.Charge.retrieve!(id: "ch_1tEa2FtVyao2Yb")

    charge = Stripe.Charge.retrieve!(id: "ch_1tEa2FtVyao2Yb")

    assert charge["id"] == "ch_1tEa2FtVyao2Yb"
  end

  test "valid POST" do
    {:ok, {status_code, headers, charge}} = Stripe.Charge.create(
      amount: 500,
      currency: "USD",
      customer: "cus_1u0czSrpdEB6EM"
    )

    assert status_code == 200
    assert is_list(headers) == true
    assert charge["id"] != nil
  end

  test "invalid POST" do
    {:error, {status_code, _headers, result}} = Stripe.Charge.create(amount: 5)

    assert status_code == 400
    assert result["error"]["type"] == "invalid_request_error"
  end

  test "valid POST!" do
    charge = Stripe.Charge.create!(
      amount: 500,
      currency: "USD",
      customer: "cus_1u0czSrpdEB6EM"
    )

    assert charge["id"] != nil
  end

  test "invalid POST!" do
    try do
      Stripe.Charge.create!(amount: 5)
    rescue
      err in [Okapi.Resource.BadRequest] -> assert err.code == 400
    end
  end
end
