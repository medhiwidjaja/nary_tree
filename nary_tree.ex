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

  def to_list(%NaryTree{} = tree), do: to_list(tree, %{})
  defp to_list(%NaryTree{children: %{}} = node, _acc), do: [node.id]
  defp to_list(%NaryTree{children: children} = tree, acc) do
    reduced_children = for child <- children do
      to_list(child, acc)
    end
    List.flatten([tree | reduced_children])
  end

  # def print_tree(%NaryTree{id: id, content: content, parent: parent}) when parent == :empty do
  #   IO.puts "#{id} - #{content.name}"
  # end
  def print_tree(%NaryTree{children: children} = node) when children == %{} do
    IO.puts "#{node.id} - #{node.content.name}"
  end
  def print_tree(%NaryTree{children: children}) do
    Enum.each Map.values(children), &print_tree(&1)
  end

  defimpl Enumerable do
    def count(%NaryTree{} = tree), do: {:ok, count(tree, 0)}

    defp count(%NaryTree{children: children}, acc) when children == %{}, do: acc + 1 # This counts the leaves
    defp count(%NaryTree{children: children}, acc) do
      Enum.sum(Enum.map(Map.values(children), &count(&1, acc))) + 1
    end

    def member?(%NaryTree{id: id}, id), do: IO.inspect("Yes, #{id}"); {:ok, true}
    def member?(%NaryTree{children: children, id: id}, elem_id)
        when children == %{}
        and id != elem_id do
      IO.inspect("No, #{id}");
      {:ok, false}
    end
    def member?(%NaryTree{children: children}, elem_id) do
      Enum.any?(Map.values(children), fn(child) -> IO.inspect("Wait, #{child.id}"); Enum.member? child, elem_id end)
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

