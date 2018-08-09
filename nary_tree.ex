defmodule NaryTree do

  # @enforce_keys [:id, :children]
  defstruct id: :empty, content: :empty, parent: :empty, children: %{}

  @type t :: %NaryTree{id: any(), content: any(), parent: any(), children: [%NaryTree{}]}

  def new(), do: %NaryTree{id: :empty, content: :empty, parent: :empty, children: %{}}
  def new(id, content), do: %NaryTree{id: id, content: content, parent: :empty, children: %{}}

  def add_child(parent, %NaryTree{id: id} = child) do
    %NaryTree{ parent | children: Map.put(parent.children, id, %NaryTree{child | parent: parent.id}) }
  end

  def is_root?(node), do: node.parent == :empty || node.parent == nil

  def is_leaf?(node), do: node.children == %{}

  def map(%NaryTree{children: children} = node, func) when children == %{} do
    %NaryTree{func.(node) | children: %{}}
  end
  def map(%NaryTree{children: children} = node, func) do
    updated_children = Enum.reduce children, children, fn(child, acc) -> %{acc | child.k => func.(child)} end
    %NaryTree{func.(node) | children: updated_children}
  end

  def flatten(%NaryTree{children: children} = node) when children == %{}, do: [node]
  def flatten(%NaryTree{children: children} = tree) do
    node = %NaryTree{ tree | children: %{}}
    List.flatten [node | Enum.map(Map.values(children), fn(child) -> flatten(child) end)]
  end

  # TODO : there's a bug in here
  def print_tree(%NaryTree{children: children} = node) when children == %{} do
    IO.puts "  #{node.id} - #{node.content.name}"
  end
  def print_tree(%NaryTree{id: id, content: content, children: children}) do
    IO.puts "#{id} - #{content.name}"
    Enum.each Map.values(children), fn(child) ->
      IO.write "  "
      print_tree(child)
    end
  end

  defimpl Enumerable do
    def count(%NaryTree{} = tree), do: {:ok, count(tree, 0)}

    defp count(%NaryTree{children: children}, acc) when children == %{}, do: acc + 1 # This counts the leaves
    defp count(%NaryTree{children: children}, acc) do
      Enum.sum(Enum.map(Map.values(children), &count(&1, acc))) + 1
    end

    def member?(%NaryTree{id: id}, id), do: {:ok, true}
    def member?(%NaryTree{children: children}, _elem_id) when children == %{} do
      {:ok, false}
    end
    def member?(%NaryTree{id: id, children: children}, elem_id)
        when children != %{} and id == elem_id do
      {:ok, true}
    end
    def member?(%NaryTree{id: id, children: children}, elem_id) when children != %{} do
      if Enum.any?(Map.values(children), fn(child) -> Enum.member? child, elem_id end) do
        {:ok, true}
      else
        {:ok, false}
      end
    end

    def reduce(tree, acc, f) do
      reduce_tree(NaryTree.to_list(tree), acc, f)
    end

    defp reduce_tree(_, {:halt, acc}, _f), do: {:halted, acc}
    defp reduce_tree(tree, {:suspend, acc}, f), do: {:suspended, acc, &reduce_tree(tree, &1, f)}
    defp reduce_tree(%{}, {:cont, acc}, _f), do: {:done, acc}
    defp reduce_tree([h | t], {:cont, acc}, f), do: reduce_tree(t, f.(h, acc), f)

    def slice(_tree) do
      {:error, __MODULE__}        # let the default action take over
    end
  end
end

# root = NT.new 0, %{w: 0.45, name: "Goal"}
# c1 = NT.new 1, %{w: 0.33, name: "Cost"}
# c2 = NT.new 2, %{w: 0.67, name: "Benefits"}
# a1 = NT.new 3, %{w: 0.1, name: "Alt 1"}
# a2 = NT.new 4, %{w: 0.4, name: "Alt 2"}
# a3 = NT.new 5, %{w: 0.5, name: "Alt 3"}
# c11 = NT.new 6, %{w: 0.2, name: "Speed"}
# c12 = NT.new 7, %{w: 0.3, name: "Image"}
# c13 = NT.new 8, %{w: 0.5, name: "Features"}
# c1 = c1 |> NT.add_child(a1) |> NT.add_child(a2) |> NT.add_child(a3)
# c2.children |> Map.put(c11.id, c11) |> Map.put(c12.id, c12) |> Map.put(c13.id, c13)

# tree = root |> NT.add_child(c1 |> NT.add_child(a1) |> NT.add_child(a2) |> NT.add_child(a3)) |>
#   NT.add_child(c2 |> NT.add_child(c11) |> NT.add_child(c12) |> NT.add_child(c13))
