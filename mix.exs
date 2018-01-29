defmodule Skoll.MixProject do
  use Mix.Project

  def project do
    [
      app: :skoll,
      description: "Data driven API design.",
      version: "0.0.1",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "Skoll",
      source_url: "https://github.com/IanLuites/skoll",
      homepage_url: "https://github.com/IanLuites/skoll",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def package do
    [
      name: :skoll,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        # Elixir
        "lib/skoll.ex",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      links: %{
        "GitHub" => "https://github.com/IanLuites/skoll"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end
end
