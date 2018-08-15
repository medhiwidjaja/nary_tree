defmodule NaryTree do

  defmodule Node do
    @enforce_keys [:id]
    defstruct id: :empty, name: :empty, content: :empty, parent: :empty, level: 0, children: []

    @type t :: %__MODULE__{id: String.t, name: String.t, content: any(), parent: String.t, children: []}

    @spec new() :: __MODULE__.t()
    def new(), do: %__MODULE__{id: create_id(), name: :empty, content: :empty, parent: :empty, children: []}
    def new(name, content), do: %__MODULE__{id: create_id(), name: name, content: content, parent: :empty, children: []}

    defp create_id, do: Integer.to_string(:rand.uniform(4294967296), 32)
  end

  alias NaryTree.Node

  defstruct root: nil, nodes: %{}

  @type t :: %__MODULE__{root: String.t, nodes: [%__MODULE__{}]}

  @spec new() :: __MODULE__.t()
  def new(), do: %__MODULE__{}

  @spec new(Node.t()) :: __MODULE__.t()
  def new(%Node{} = node) do
    %__MODULE__{root: node.id, nodes: %{node.id => node}}
  end

  # @spec add_child(__MODULE__.t(), Node.t()) :: __MODULE__.t()
  def add_child(%__MODULE__{nodes: nodes} = tree, parent_id, %Node{id: child_id} = child) do
    parent = tree.nodes[parent_id]
    updated_nodes = nodes
      |> Map.put_new(child_id, %Node{child | parent: parent.id, level: parent.level + 1})
      |> Map.put(parent.id, %Node{parent | children: parent.children ++ [child_id] })
    %__MODULE__{tree | nodes: updated_nodes}
  end

  @spec is_root?(Node.t()) :: boolean()
  def is_root?(%Node{} = node), do: node.parent == :empty || node.parent == nil

  @spec is_leaf?(Node.t()) :: boolean()
  def is_leaf?(%Node{} = node), do: node.children == []

  @spec has_content?(Node.t()) :: boolean()
  def has_content?(%Node{} = node), do: node.content != nil

  @spec update_content(__MODULE__.t(), function()) :: __MODULE__.t()
  def update_content(%__MODULE__{nodes: nodes} = tree, func) do
    %__MODULE__{tree | nodes: Enum.map(nodes, fn(node) -> %Node{node | content: func.(node.content)} end) }
  end

  # def update_content(%__MODULE__{content: content, children: []} = node, func) do
  #   %__MODULE__{node | content: func.(content)}
  # end
  # def update_content(%__MODULE__{content: content, children: children} = tree, func) do
  #   updated_children = Enum.reduce children, children,
  #     fn(child_id, acc) -> %{acc | id => update_content(child, func)} end
  #   %__MODULE__{node | content: func.(content), children: updated_children}
  # end

  # def flatten(%__MODULE__{children: children} = node) when children == %{}, do: [node]
  # def flatten(%__MODULE__{children: children} = tree) do
  #   node = %__MODULE__{ tree | children: %{}}
  #   List.flatten [node | Enum.map(children, fn({_, child}) -> flatten(child) end)]
  #   |> :lists.reverse()
  # end

  # def search(%__MODULE__{children: children} = tree, id) when children == %{} do
  #   if tree.id == id, do: tree, else: nil
  # end
  # def search(%__MODULE__{id: id, children: _children} = node, id), do: node
  # def search(%__MODULE__{children: children}, id) do
  #   if Map.has_key?(children, id) do
  #     Map.get(children, id)
  #   else
  #     Enumerable.reduce(Map.values(children), {:cont, nil}, fn child, _ ->
  #       found = __MODULE__.search(child, id)
  #       if found, do: {:halt, found}, else: {:cont, nil}
  #     end)
  #     |> elem(1)
  #   end
  # end

  # TODO : there's a bug in here
  def print_tree(%__MODULE__{} = tree, func) do
    do_print_tree(%Node{} = tree.nodes[tree.root], tree.nodes, func)
  end

  defp do_print_tree(%Node{children: children} = node, _nodes, func) when children == [] do
    IO.puts indent(node.level) <> "- " <> func.(node)
  end
  defp do_print_tree(%Node{children: children} = node, nodes, func) do
    IO.puts indent(node.level) <> "* " <> func.(node)
    Enum.each children, fn(child_id) -> do_print_tree(nodes[child_id], nodes, func) end
  end

  def indent(n, c \\ " ") do
    String.duplicate(c, n*2)
  end

  defp is_nary_tree?(%__MODULE__{}), do: true
  defp is_nary_tree?(_), do: false

  def move_nodes(tree, child_ids, new_parent_id) do
    new_parent_node = tree.nodes[new_parent_id]
    pid = tree.nodes[hd child_ids].parent
    updated_nodes = Enum.reduce(child_ids, tree.nodes, fn(cid, acc) ->
        Map.put acc, cid, %Node{ acc[cid] | parent: new_parent_id}
      end)
      |> Map.put(pid, %Node{ tree.nodes[pid] | children: tree.nodes[pid].children -- child_ids })
      |> Map.put(new_parent_id, %Node { new_parent_node | children: new_parent_node.children ++ child_ids })
    %__MODULE__{ tree | nodes: updated_nodes }
  end

  def get(%__MODULE__{nodes: nodes}, id), do: Map.get nodes, id

  def put(%__MODULE__{nodes: nodes}, id, update), do: Map.put nodes, id, update

  def delete(%__MODULE__{nodes: nodes} = tree, id) do
    node = nodes[id]
    tree
    |> IO.inspect()
    |> unlink_from_parent(node)
    |> IO.inspect()
    |> move_nodes(node.children, node.parent)
    |> IO.inspect()
    |> delete_node(id)
    |> IO.inspect()
  end

  defp unlink_from_parent(tree, %Node{parent: parent}) when parent == :empty or parent == nil, do: tree
  defp unlink_from_parent(tree, node) do
    parent = tree.nodes[node.parent]
    updated_parent = %Node{ parent | children: (parent.children -- [node.id]) }
    %__MODULE__{ tree | nodes: Map.put(tree.nodes, node.parent, updated_parent) }
  end

  defp delete_node(tree, id) do
    %__MODULE__{ tree | nodes: Map.delete(tree.nodes, id) }
  end

  @behaviour Access

  @spec fetch(__MODULE__.t(), String.t()) :: {:ok, Node.t()} | :error
  def fetch(%__MODULE__{nodes: nodes}, id) do
    if Map.has_key?(nodes, id), do: {:ok, nodes[id]}, else: :error
  end

  def get_and_update(%__MODULE__{} = tree, id, fun) when is_function(fun, 1) do
    current = get(tree, id)

    case fun.(current) do
      {get, update} ->
        {get, put(tree, id, update)}

      :pop ->
        {current, delete(tree, id)}

      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end

  # defimpl Enumerable do
  #   def count(%NaryTree{nodes: nodes}), do: {:ok, Map.size(nodes)}

  #   def member?(%NaryTree{nodes: %{id: id}}, id), do: {:ok, true}
  #   def member?(_,_), do: {:ok, false}

  #   def reduce(%NaryTree{nodes: nodes}, acc, f) do
  #     reduce_tree(nodes, acc, f)
  #   end

  #   defp reduce_tree(_, {:halt, acc}, _f), do: {:halted, acc}
  #   defp reduce_tree(nodes, {:suspend, acc}, f), do: {:suspended, acc, &reduce_tree(nodes, &1, f)}
  #   defp reduce_tree([], {:cont, acc}, _f), do: {:done, acc}
  #   defp reduce_tree([h | t], {:cont, acc}, f), do: reduce_tree(t, f.(h, acc), f)

  #   def slice(_tree) do
  #     {:error, NaryTree}        # let the default action take over
  #   end
  # end
end

# alias __MODULE__, as: NT
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
