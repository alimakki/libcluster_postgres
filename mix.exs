defmodule LibclusterPostgres.MixProject do
  use Mix.Project

  def project do
    [
      app: :libcluster_postgres,
      version: "0.1.0",
      name: "libcluster_postgres",
      description: description(),
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def description do
    """
    Postgres LISTEN/NOTIFY strategy for libcluster
    """
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:libcluster, "~> 3.3"},
      {:postgrex, "~> 0.16.1"}
    ]
  end
end
