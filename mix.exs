defmodule Okapi.Mixfile do
  use Mix.Project

  def project do
    [ app: :okapi,
      name: "Okapi",
      version: "0.0.1",
      elixir: "~> 0.12.1-dev",
      deps: deps,
      source_url: "https://github.com/raycmorgan/okapi" ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [ { :jsex, "~> 0.2", github: "talentdeficit/jsex" },
      { :ex_doc, github: "elixir-lang/ex_doc" } ]
  end
end
