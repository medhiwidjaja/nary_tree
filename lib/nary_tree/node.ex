defmodule NaryTree.Node do
    @moduledoc """
      ## NaryTree.Node
  
      NaryTree.Node encapsulates functions for creating a node in nary_tree.
  
      Each node is assigned a random ID to be used as index in the tree
    """
  
    @enforce_keys [:id]
    defstruct id: :empty, name: :empty, type: :empty, content: :empty, parent: :empty, level: 0, children: []
  
    @type t :: %__MODULE__{id: String.t, name: String.t, type: String.t, content: any(), parent: String.t, children: []}
  
    @doc ~S"""
    Create a new, empty node.
    """
    @spec new(String.t()) :: __MODULE__.t()
    def new(id), do: %__MODULE__{id: create_id(id), name: :empty, type: :empty, content: :empty, parent: :empty, children: []}
  
    @doc ~S"""
    Create a new, empty node with name.
  
    ## Example
        iex> %NaryTree.Node{name: name, level: 0, children: []} = NaryTree.Node.new(1, "Node")
        iex> name
        "Node"
    """
    def new(id, name), do: %__MODULE__{id: create_id(id), name: name, type: :empty, content: :empty, parent: :empty, children: []}

    @doc ~S"""
    Create a new, empty node with name.
  
    ## Example
        iex> %NaryTree.Node{name: name, level: 0, children: []} = NaryTree.Node.new(1, "Node")
        iex> name
        "Node"
    """
    def new(id, name, type), do: %__MODULE__{id: create_id(id), name: name, type: type, content: :empty, parent: :empty, children: []}
  
    @doc ~S"""
    Create a new, empty node with name and content.
  
    ## Example
        iex> %NaryTree.Node{name: name, content: content, level: 0, children: []} = NaryTree.Node.new(1, "Root", %{w: 100})
        iex> name
        "Root"
        iex> content
        %{w: 100}
    """
    def new(id, name, type, content), do: %__MODULE__{id: create_id(id), name: name, type: type, content: content, parent: :empty, children: []}
  
    defp create_id(id), do: id || Integer.to_string(:rand.uniform(4294967296), 32)
  end