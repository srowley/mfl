defmodule MFL.MixProject do
  use Mix.Project

  def project do
    [
      app: :mfl,
      version: "0.2.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "MFL",
      docs: [main: "MFL",
             extras: ["README.md"]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MFL.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:bypass, "~> 1.0", only: :test},
      {:ex_doc, "~>0.19", only: :dev, runtime: false},
      {:httpoison, "~> 1.5"}
    ]
  end
end
