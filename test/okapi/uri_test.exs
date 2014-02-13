defmodule OkapiTest.URI do
  use ExUnit.Case, async: true
  alias Okapi.URI

  test "should encode simple params" do
    assert URI.encode_query(id: "123", name: "Jim") == "id=123&name=Jim"
  end

  test "should encode simple nested params" do
    assert URI.encode_query(id: "123", person: [name: "Jim"]) == "id=123&person[name]=Jim"
  end

  test "should encode more complex params" do
    assert URI.encode_query(
      id: "123",
      person: [name: [first: "Jim", last: "Raynor"], age: 34],
      count: 1
    ) == "id=123&person[name][first]=Jim&person[name][last]=Raynor&person[age]=34&count=1"
  end

  test "should handle duplicate params" do
    assert URI.encode_query(foo: "bar", foo: "baz") == "foo=bar&foo=baz"
  end
end
