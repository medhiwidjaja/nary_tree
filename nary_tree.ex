defmodule NaryTree do

  # @enforce_keys [:id, :children]
  defstruct id: :empty, content: :empty, parent: :empty, children: []

  @type t :: %NaryTree{id: any(), content: any(), parent: any(), children: [%NaryTree{}]}

  def new(), do: %NaryTree{id: :empty, content: :empty, parent: :empty, children: []}
  def new(id, content), do: %NaryTree{id: id, content: content, parent: :empty, children: []}

  def add_child(parent, %NaryTree{} = child) do
    %NaryTree{parent | children: [ %NaryTree{child | parent: parent.id} ]}
  end

  def is_root?(node), do: node.parent == nil

  def is_leaf?(node), do: node.children == []

  def map(%NaryTree{children: []} = node, func) do
    func.(node)
  end
  def map(%NaryTree{children: children} = node, func) do
    updated_children = for child <- children, do: map(child, func)
    #%NaryTree{func.(node) | children: updated_children}
    func.(node)
  end

  def to_list(%NaryTree{} = tree), do: to_list(tree, [])
  defp to_list(%NaryTree{children: []} = node, _acc), do: [node]
  defp to_list(%NaryTree{children: children} = tree, acc) do
    reduced_children = for child <- children do
      to_list(child, acc)
    end
    List.flatten([tree | reduced_children])
  end

  # def print_tree(%NaryTree{} = tree) do

  # end

  defimpl Enumerable do
    def count(%NaryTree{} = tree), do: {:ok, count(tree, 0)}

    defp count(%NaryTree{children: []}, acc), do: acc + 1 # This counts the leaves
    defp count(%NaryTree{children: children}, acc) do
      Enum.sum(Enum.map(children, &count(&1, acc))) + 1
    end

    def member?(%NaryTree{id: id}, id), do: {:ok, true}
    def member?(%NaryTree{id: id, children: []}, elem_id) when id != elem_id, do: {:ok, false}
    def member?(%NaryTree{} = tree, elem_id) do
      {:ok, member?(tree, elem_id, false)}
    end

    defp member?(%NaryTree{children: children}, elem, acc) do
      Enum.reduce(children, acc, fn(child, acc) ->
        {:ok, res} = member?(child, elem)
        if res, do: true, else: acc
      end)
    end

    def reduce(tree, acc, f) do
      reduce_tree(NaryTree.to_list(tree), acc, f)
    end

    defp reduce_tree(_, {:halt, acc}, _f), do: {:halted, acc}
    defp reduce_tree(tree, {:suspend, acc}, f), do: {:suspended, acc, &reduce_tree(tree, &1, f)}
    defp reduce_tree([], {:cont, acc}, _f), do: {:done, acc}
    defp reduce_tree([h | t], {:cont, acc}, f), do: reduce_tree(t, f.(h, acc), f)
  end
end

