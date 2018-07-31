defmodule Node1.MixProject do
  use Mix.Project

  def project do
    [
      app: :node1,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Node1, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nadia, "~> 0.4.4"},
      {:amqp, "~> 0.2.3"},
      {:distillery, "~> 1.5", runtime: false},
      {:exvcr, "~> 0.10.1", only: [:dev, :test]},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false}
    ]
  end
end
