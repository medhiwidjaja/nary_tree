defmodule Node do
  @enforce_keys [:id]
  defstruct id: :empty, name: :empty, content: :empty, parent: :empty, level: 0, children: []

  @type t :: %__MODULE__{id: String.t, name: String.t, content: any(), parent: String.t, children: []}

  @spec new() :: __MODULE__.t()
  def new(), do: %__MODULE__{id: create_id(), name: :empty, content: :empty, parent: :empty, children: []}
  def new(name, content), do: %__MODULE__{id: create_id(), name: name, content: content, parent: :empty, children: []}

  defp create_id, do: Integer.to_string(:rand.uniform(4294967296), 32)
end
