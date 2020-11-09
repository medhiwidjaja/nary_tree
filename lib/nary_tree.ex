defmodule NaryTree do

  @moduledoc """
  NaryTree implements a data structure for an n-ary tree in which each node has zero or more children. 
  A node in a tree can have arbitrary number of children and depth. Trees are unbalanced and children unordered.
  """

  defstruct root: nil, nodes: %{}

  alias NaryTree.Node

  @type t :: %__MODULE__{root: String.t, nodes: [%__MODULE__{}]}

  @doc ~S"""
  Create a new, empty tree.

  ## Example
      iex> NaryTree.new()
      %NaryTree{nodes: %{}, root: :empty}
  """
  @spec new() :: __MODULE__.t()
  def new(), do: %__MODULE__{root: :empty}

  @doc ~S"""
  Create a new tree with a root node.

  ## Example
      iex> %NaryTree{root: key, nodes: nodes} = NaryTree.new(NaryTree.Node.new(1, "Root node"))
      iex> nodes[key].name
      "Root node"
  """
  @spec new(Node.t()) :: __MODULE__.t()
  def new(%Node{} = node) do
    root = %Node{ node | parent: :empty, level: 0 }
    %__MODULE__{root: root.id, nodes: %{root.id => root}}
  end

  @doc ~S"""
  Add a child node to a tree root node. Returns an updated tree with added child.

          RootNode
          \
          ChildNode

  ## Example
      iex> tree = NaryTree.new(NaryTree.Node.new(1, "Root node")) |>
      ...>   NaryTree.add_child(NaryTree.Node.new(2, "Child"))
      iex> %NaryTree{root: key, nodes: nodes} = tree
      iex> [child_id | _] = nodes[key].children
      iex> nodes[child_id].name
      "Child"
  """
  @spec add_child(__MODULE__.t(), Node.t()) :: __MODULE__.t()
  def add_child(%__MODULE__{} = tree, %Node{} = child) do
    add_child(tree, child, tree.root)
  end

  @doc ~S"""
  Add a child node to the specified tree node. Returns an updated tree with added child.

        RootNode
          \
          BranchNode
              \
              New node

  ## Example
      iex> branch = NaryTree.Node.new(3, "Branch Node")
      iex> tree = NaryTree.new(NaryTree.Node.new(1, "Root Node")) |>
      ...>   NaryTree.add_child(branch) |>
      ...>   NaryTree.add_child(NaryTree.Node.new(4, "New node"), branch.id)
      iex> Enum.count tree.nodes
      3
  """
  def add_child(_, %Node{id: child_id}, parent_id) when parent_id == child_id do
    raise "Cannot add child to its own node"
  end
  def add_child(%__MODULE__{nodes: nodes} = tree, %Node{id: child_id} = child, parent_id) do
    parent = tree.nodes[parent_id]
    updated_nodes = nodes
      |> Map.put_new(child_id, %Node{child | parent: parent.id, level: parent.level + 1})
      |> Map.put(parent.id, %Node{parent | children: List.delete(parent.children, child_id) ++ [child_id] })
    %__MODULE__{tree | nodes: updated_nodes}
  end

  @doc ~S"""
  Check whether a node is a root node.

  ## Example
      iex> node = NaryTree.Node.new(1, "Root node")
      iex> NaryTree.is_root? node
      true
  """
  @spec is_root?(Node.t()) :: boolean()
  def is_root?(%Node{} = node), do: node.parent == :empty || node.parent == nil

  @doc ~S"""
  Check whether a node is a leaf node.

  ## Example
      iex> tree = NaryTree.new(NaryTree.Node.new(1, "Root node")) |>
      ...>   NaryTree.add_child(NaryTree.Node.new(2, "Leaf node"))
      iex> [node_id] = tree.nodes[tree.root].children
      iex> leaf_node = tree.nodes[node_id]
      iex> NaryTree.is_leaf? leaf_node
      true
  """
  @spec is_leaf?(Node.t()) :: boolean()
  def is_leaf?(%Node{} = node), do: node.children == []

  @doc ~S"""
  Check whether a node has non-empty content.

  ## Example
      iex> node = NaryTree.Node.new(1, "Node", content: %{c: "Content"})
      iex> NaryTree.has_content? node
      true
  """
  @spec has_content?(Node.t()) :: boolean()
  def has_content?(%Node{} = node), do: !(node.content == nil || node.content == :empty)

  @doc ~S"""
  Enumerates tree nodes, and applies function to each node's content.
  Returns updated tree, with new content for every nodes

  ## Example
      iex> tree = NaryTree.new(NaryTree.Node.new(1, "Root node")) |>
      ...>   NaryTree.add_child(NaryTree.Node.new(2, "Leaf node 1")) |>
      ...>   NaryTree.add_child(NaryTree.Node.new(3, "Leaf node 2"))
      iex> Enum.map tree.nodes, fn({_,node}) -> node.content end
      [:empty, :empty, :empty]
      iex> NaryTree.update_content(tree, fn(_) -> %{x: 4} end) |>
      ...>   Map.get(:nodes) |> Enum.map(fn({_,node}) -> node.content end)
      [%{x: 4}, %{x: 4}, %{x: 4}]
  """
  @spec update_content(__MODULE__.t(), function()) :: __MODULE__.t()
  def update_content(%__MODULE__{nodes: nodes} = tree, func) do
    %__MODULE__{tree | nodes: do_update_content(nodes, func)}
  end

  defp do_update_content(nodes, func) do
    Enum.reduce(nodes, nodes, fn({id, node}, acc) ->
      Map.put(acc, id, Map.update!(node, :content, func))
    end)
  end

  @doc ~S"""
  Enumerates tree nodes, and applies function to each leaf nodes' content.
  Similar to `update_content/2`, but applies only to leaf nodes.

  """
  @spec each_leaf(__MODULE__.t(), function()) :: __MODULE__.t()
  def each_leaf(%__MODULE__{nodes: nodes} = tree, func) do
    %__MODULE__{tree | nodes: do_each_leaf(nodes, func)}
  end

  defp do_each_leaf(nodes, func) do
    Enum.reduce(nodes, nodes, fn({_,node}, acc) ->
      if is_leaf?(node) do
        Map.put(acc, node.id, Map.update!(node, :content, func))
      else
        acc
      end
    end)
  end

  @doc ~S"""
  Check whether the argument is of NaryTree type.

  ## Example
      iex> NaryTree.is_nary_tree? NaryTree.new(NaryTree.Node.new(1, "Node"))
      true
  """
  @spec is_nary_tree?(__MODULE__.t()) :: boolean()
  def is_nary_tree?(%__MODULE__{}), do: true
  def is_nary_tree?(_), do: false

  @doc ~S"""
  Move children nodes from one node to another node.

  """
  @spec move_nodes(__MODULE__.t(), [Node.t()], Node.t()) :: __MODULE__.t()
  def move_nodes(tree, [], _), do: tree
  def move_nodes(tree, nodes, %Node{} = new_parent) do
    move_nodes(tree, Enum.map(nodes, &(&1.id)), new_parent.id)
  end

  @spec move_nodes(__MODULE__.t(), [String.t()], String.t()) :: __MODULE__.t()
  def move_nodes(tree, child_ids, new_parent_id) do
    new_parent_node = tree.nodes[new_parent_id]
    pid = tree.nodes[hd child_ids].parent
    updated_nodes = Enum.reduce(child_ids, tree.nodes, fn(cid, acc) ->
        Map.put acc, cid, %Node{ acc[cid] | parent: new_parent_id, level: new_parent_node.level+1}
      end)
      |> Map.put(pid, %Node{ tree.nodes[pid] | children: tree.nodes[pid].children -- child_ids })
      |> Map.put(new_parent_id, %Node { new_parent_node | children: new_parent_node.children ++ child_ids })
    %__MODULE__{ tree | nodes: updated_nodes }
  end

  @doc ~S"""
  Get the node with the specified id from the tree.

  ## Example
      iex> node = NaryTree.Node.new(1, "Node")
      iex> n = NaryTree.new(node) |>
      ...>     NaryTree.get(node.id)
      iex> n.name
      "Node"
  """
  def get(%__MODULE__{nodes: nodes}, id), do: Map.get nodes, id

  @doc ~S"""
  Put a node into the tree at the specified id.
  Put will replace the name and content attributes of the node at id with
  the attributes of the new nodes.
  The children and parent of the old node will remain the same so that
  the hierarchy structure remains the same.

  ## Example
      iex> tree = NaryTree.new NaryTree.Node.new(1, "Root")
      iex> tree.nodes[tree.root].name
      "Root"
      iex> tree = NaryTree.put(tree, tree.root, NaryTree.Node.new(2, "Node"))
      iex> tree.nodes[tree.root].name
      "Node"
  """
  def put(%__MODULE__{nodes: nodes} = tree, id, node_to_replace) do
    updated_node = %Node{nodes[id] | content: node_to_replace.content, name: node_to_replace.name}
    %__MODULE__{ tree | nodes: Map.put(nodes, id, updated_node) }
  end

  @doc ~S"""
  Delete a node in a tree.
  If the deleted node has children, the children will be moved up in hierarchy
  to become the children of the deleted node's parent. 

  Deleting root node results in `:error`

  ## Example
      iex> branch = NaryTree.Node.new(1, "Branch Node")
      iex> leaf = NaryTree.Node.new(2, "Leaf")
      iex> tree = NaryTree.new(NaryTree.Node.new(3, "Root Node")) |>
      ...>   NaryTree.add_child(branch) |>
      ...>   NaryTree.add_child(leaf, branch.id) |>
      ...>   NaryTree.delete(branch.id)
      iex> tree.nodes[branch.id]
      nil
      iex> tree.nodes[tree.root].children   # leaf becomes root's child
      [leaf.id]
  """
  @spec delete(NaryTree.t(), any()) :: :error
  def delete(%__MODULE__{} = tree, %Node{id: id}), do: delete(tree, id)
  def delete(%__MODULE__{root: root}, id) when id == root, do: :error
  def delete(%__MODULE__{nodes: nodes} = tree, id) do
    if Enum.member? tree, id do
      node = nodes[id]
      tree
      |> unlink_from_parent(node)
      |> move_nodes(node.children, node.parent)
      |> delete_node(id)
    else
      :error
    end
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

  @doc ~S"""
  Detach a branch in a tree. Returns the detached branch conplete with all its
  descendents as a new tree struct.

  ## Example
      iex> branch = NaryTree.Node.new(1, "Branch Node")
      iex> leaf = NaryTree.Node.new(2, "Leaf")
      iex> tree = NaryTree.new(NaryTree.Node.new(3, "Root Node")) |>
      ...>   NaryTree.add_child(branch) |>
      ...>   NaryTree.add_child(leaf, branch.id)
      iex> detached = NaryTree.detach(tree, branch.id)
      iex> Enum.count detached.nodes
      2
      iex> detached.root
      branch.id
  """
  def detach(%__MODULE__{} = tree, node_id) when is_binary(node_id) or is_number(node_id) do
    if Enum.member? tree, node_id do
      root = get(tree, node_id)
      new_tree = new root
      Enum.reduce root.children, new_tree, fn(child_id, acc) ->
        add_all_descendents(acc, root.id, child_id, tree)
      end
    else
      :error
    end
  end

  defp add_all_descendents(tree, parent_id, node_id, old_tree) do
    node = get old_tree, node_id
    case node.children do
      [] ->
        add_child(tree, node, parent_id)
      _ ->
        new_tree = add_child(tree, node, parent_id)
        Enum.reduce node.children, new_tree, fn(child_id, acc) ->
          add_all_descendents(acc, node.id, child_id, old_tree)
        end
    end
  end

  @doc ~S"""
  Merges a tree into another tree at the specified node point.
  Returns the resulting combined tree or `:error` if the specified
  node point doesn't exist.

  ## Example
      iex> branch = NaryTree.Node.new(1, "Branch Node")
      iex> tree1 = NaryTree.new(NaryTree.Node.new(2, "Root Node")) |>
      ...>   NaryTree.add_child(branch)
      iex> tree2 = NaryTree.new(NaryTree.Node.new(3, "Subtree")) |>
      ...>   NaryTree.add_child(NaryTree.Node.new(4, "Leaf"))
      iex> combined = NaryTree.merge(tree1, tree2, branch.id)
      iex> Enum.count combined.nodes
      4
  """
  def merge(%__MODULE__{} = tree,
            %__MODULE__{} = branch,
            node_id)
            when is_binary(node_id) or is_number(node_id) do
    if Enum.member? tree, node_id do
      node = get(tree, node_id)
      updated_node = node |> Map.put(:children, node.children ++ [branch.root])
      tree_nodes = Map.put tree.nodes, node_id, updated_node
      branch_nodes = branch.nodes
        |> Enum.reduce(branch.nodes, fn({id, n}, acc) ->
              Map.put acc, id, %Node{ n | level: n.level + node.level + 1 }
            end)
        |> Map.put(branch.root, %Node{ root(branch) | parent: node.id , level: node.level + 1 })
      %__MODULE__{ tree | nodes: Map.merge(tree_nodes, branch_nodes) }
    else
      :error
    end
  end

  # Familial Relationships

  @doc ~S"""
  Returns the root node of a tree.

  ## Example
      iex> tree = NaryTree.new(NaryTree.Node.new(1, "Root Node"))
      iex> %NaryTree.Node{name: name} = NaryTree.root(tree)
      iex> name
      "Root Node"
  """
  def root(%__MODULE__{} = tree) do
    get tree, tree.root
  end

  @doc ~S"""
  Returns the children nodes of a tree.

  """
  def children(%Node{} = node, %__MODULE__{} = tree) do
    Enum.map node.children, &(get tree, &1)
  end

  @doc ~S"""
  Returns the parent node of a tree, or `:empty` if there is none

  ## Example
      iex> branch = NaryTree.Node.new(1, "Branch Node")
      iex> tree = NaryTree.new(NaryTree.Node.new(2, "Root Node")) |>
      ...>   NaryTree.add_child(branch)
      iex> %NaryTree.Node{name: name} = NaryTree.root(tree)
      iex> name
      "Root Node"
  """
  def parent(%Node{} = node, %__MODULE__{} = tree) do
    get tree, node.parent
  end

  @doc ~S"""
  Returns the sibling nodes of a node.
  
  """
  def siblings(%Node{} = node, %__MODULE__{} = tree) do
  parent(node, tree)
    |> children(tree)
    |> List.delete(node)
  end

  @doc ~S"""
  Prints a tree in hierarchical fashion. 
  The second parameter is an optional function that accepts a node as a parameter.
  `print_tree` will output the return value of the function for each node in the tree.

  ## Example
    `iex> NaryTree.print_tree tree, fn(node) -> "#{x.name} : {x.content}" end`

    or 

    `iex> NaryTree.print_tree tree, &("#{&1.name}: #{&1.id}")`
  
  """
  def print_tree(%__MODULE__{} = tree, func \\ fn(x) -> "#{x.name}" end) do
    do_print_tree(%Node{} = tree.nodes[tree.root], tree.nodes, func)
  end

  defp do_print_tree(node, _, _) when is_nil(node), do: raise "Expecting %NaryTree.Node(), found nil."
  defp do_print_tree(%Node{children: children} = node, _nodes, func) when children == [] do
    IO.puts indent(node.level) <> "- " <> func.(node)
  end
  defp do_print_tree(%Node{children: children} = node, nodes, func) do
    IO.puts indent(node.level) <> "* " <> func.(node)
    Enum.each children, fn(child_id) -> do_print_tree(nodes[child_id], nodes, func) end
  end

  defp indent(n, c \\ " ") do
    String.duplicate(c, n*2)
  end

  @behaviour Access

  @spec fetch(__MODULE__.t(), String.t()) :: {:ok, Node.t()} | :error
  def fetch(%__MODULE__{nodes: nodes}, id) do
    if Map.has_key?(nodes, id), do: {:ok, nodes[id]}, else: :error
  end

  @doc ~S"""
  Invoked in order to access a node in a tree and update it at the same time

  ## Example 
      iex> tree = NaryTree.new NaryTree.Node.new(1, "Root")
      iex> {old_node, new_tree} = NaryTree.get_and_update tree, tree.root, &({&1, %NaryTree.Node{&1 | content: :not_empty}})
      iex> old_node.content
      :empty
      iex> NaryTree.root(new_tree).content
      :not_empty
    
  """
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

  @doc ~S"""
  Invoked to “pop” the specified node from the tree.

  When key exists in the tree, it returns a `{a_node, new_tree}` tuple where `a_node` is the node that was under key and `new_tree` is the tree without `a_node`.

  When key is not present in the tree, it returns `{nil, tree}`.
  """
  def pop(tree, id) do
    case delete(tree, id) do
      %__MODULE__{} = new_tree ->
        {get(tree, id), new_tree}
      :error -> {nil, tree}
    end
  end

  @doc """
  Collects nodes of a tree by using depth-first traversal. Returns a list of `NaryTree.Node` structs

  """
  def to_list(%__MODULE__{nodes: nodes} = tree) do
    traverse(%Node{} = tree.nodes[tree.root], nodes, [])
    |> :lists.reverse()
  end

  defp traverse(node, _, _) when is_nil(node), do: raise "Expecting %NaryTree.Node(), found nil."
  defp traverse(%Node{children: children} = node, _nodes, acc) when children == [] do
    [node | acc]
  end
  defp traverse(%Node{children: children} = node, nodes, acc) do
    Enum.reduce children, [node | acc], fn(child_id, accumulator) ->
      traverse nodes[child_id], nodes, accumulator
    end
  end

  @doc """
  Converts a tree into a hierarchical map with children nodes embedded in an array.
  
  Takes tree as argument, and an optional function. The function takes a node parameter
  and should return a map of attributes.
  
  The default function returns
    `%{id: node.id, name: node.name, content: node.content, level: node.level, parent: node.parent}`

  ## Example
      iex> tree = NaryTree.new(NaryTree.Node.new(1, "Root")) |>
      ...>   NaryTree.add_child(NaryTree.Node.new(2, "Leaf 1")) |>
      ...>   NaryTree.add_child(NaryTree.Node.new(3, "Leaf 2")) |>
      ...>   NaryTree.to_map( &(%{key: &1.name}) )
      %{children: [%{key: "Leaf 1"}, %{key: "Leaf 2"}], key: "Root"}
  """
  def to_map(%__MODULE__{nodes: nodes} = tree, func \\ &attr/1) do
    node_to_map(%Node{} = nodes[tree.root], tree, func)
  end

  defp node_to_map(%Node{children: children} = node, _tree, func) when children == [] do
    func.(node)
  end
  defp node_to_map(%Node{} = node, tree, func) do
    func.(node)
    |> Map.put(:children, Enum.reduce(node.children, [], fn(child_id, accumulator) ->
          [node_to_map(__MODULE__.get(tree, child_id), tree, func) | accumulator]
        end) |> :lists.reverse()
      )
  end

  defp attr(node) do
    %{id: node.id, name: node.name, content: node.content, level: node.level, parent: node.parent}
  end

  @doc """
  Converts a map into a tree

  ## Example:
    iex> tree = NaryTree.from_map %{id: 1, name: "Root", children: [%{id: 2, name: "Left"}, %{id: 3, name: "Right"}]}
    iex> Enum.count tree
    3
  """
  def from_map(%{id: id, name: name, content: content} = map) do
    tree_from_map map, new(Node.new(id, name, content)) 
  end
  def from_map(%{id: id, name: name} = map) do
    tree_from_map map, new(Node.new(id, name))
  end

  defp tree_from_map(%{children: children}, tree) do
    Enum.reduce children, tree, fn(child, tree) -> tree_from_map(child, tree.root, tree) end
  end
  defp tree_from_map(%{}, tree), do: tree

  defp tree_from_map(%{children: children} = map, id, acc) do
    node = if Map.has_key?(map, :content), do: Node.new(map[:id], map.name, map.content), else: Node.new(map[:id], map.name)
    t = add_child(acc, node, id)
    Enum.reduce children, t, fn(child, tree) -> tree_from_map(child, node.id, tree) end
  end
  defp tree_from_map(%{} = map, id, acc) do
    node = if Map.has_key?(map, :content), do: Node.new(map[:id], map.name, map.content), else: Node.new(map[:id], map.name)
    add_child(acc, node, id)
  end

  @doc """
  Converts a list of nodes back into nodes map `%{node1id => %NaryTree.Node{}, node2id => ...}`

  """
  def list_to_nodes(list) when is_list(list) do
    Enum.reduce list, %{}, fn(node, acc) ->
      Map.put_new(acc, node.id, node)
    end
  end

  defimpl Enumerable do
    def count(%NaryTree{nodes: nodes}), do: {:ok, Kernel.map_size(nodes)}

    @doc """
    ## TODO
    ## Examples
        iex> r = NaryTree.new NaryTree.Node.new(1, "Root", 3)
        ...> n = NaryTree.Node.new(2, "Branch", 100)
        ...> NaryTree.add_child r, n
        ...> Enum.member? r, n.id
        true
    """
    def member?(%NaryTree{nodes: nodes}, id) do
      case Map.has_key? nodes, id do
        true -> {:ok, true}
        false -> {:ok, false}
      end
    end

    @doc """
    ## TODO
    ## Examples
        iex> Enum.reduce tt, tt, fn(n, acc) ->
        ...>   p = NaryTree.parent(n, acc)
        ...>   pz = if p, do: p.content.w, else: 0
        ...>   NaryTree.put acc, n.id, %NaryTree.Node{n | content: %{n.content | w: n.content.w + pz}}
        ...> end
    """

    def reduce(%NaryTree{} = tree, acc, f) do
      tree
      |> NaryTree.to_list()
      |> reduce_tree(acc, f)
    end

    defp reduce_tree(_, {:halt, acc}, _f), do: {:halted, acc}
    defp reduce_tree(nodes, {:suspend, acc}, f), do: {:suspended, acc, &reduce_tree(nodes, &1, f)}
    defp reduce_tree([], {:cont, acc}, _f), do: {:done, acc}
    defp reduce_tree([h | t], {:cont, acc}, f), do: reduce_tree(t, f.(h, acc), f)

    def slice(_tree) do
      {:error, NaryTree}        # let the default action take over
    end
  end

end

