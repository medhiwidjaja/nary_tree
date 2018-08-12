defmodule NaryTree.Node do

  @enforce_keys [:id]
  defstruct id: :empty, content: :empty, parent: :empty, children: []

  @type t :: %__MODULE__{id: any(), content: any(), parent: any(), children: []}

  def new(), do: %__MODULE__{id: :empty, content: :empty, parent: :empty, children: []}
  def new(id, content), do: %__MODULE__{id: id, content: content, parent: :empty, children: []}

end
