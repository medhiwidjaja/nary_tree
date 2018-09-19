defmodule NaryTree.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nary_tree,
      version: "0.1.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "NaryTree",
      source_url: "https://github.com/medhiwidjaja/nary_tree"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def description() do
    """
    NaryTree implements the data structure for n-ary tree (also called rose tree), where
    each node in the tree can have zero or more children. NaryTree provides methods
    for traversal and manipulation of the tree structure and node contents.
    """
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, "~> 0.8.2", only: [:dev, :test]},
      {:dialyxir, "~> 0.5.0", only: [:dev, :test]}
    ]
  end

  defp package do
    [
      name: :nary_tree,
      licenses: ["MIT"],
      maintainers: ["Medhi Widjaja"],
      links: %{
        "Github" => "https://github.com/medhiwidjaja/nary_tree",
      }
    ]
  end
end
