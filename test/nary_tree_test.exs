defmodule NaryTreeTest do
  use ExUnit.Case
  doctest NaryTree

  test "updating each leaf will not update non-leaf nodes" do
    simple_tree = NaryTree.new(NaryTree.Node.new("Root node"))
      |> NaryTree.add_child(NaryTree.Node.new("Leaf node 1")) 
      |> NaryTree.add_child(NaryTree.Node.new("Leaf node 2"))
    updated_tree = NaryTree.each_leaf(simple_tree, fn(_) -> %{x: 4} end)
    root = updated_tree.nodes[updated_tree.root]
    leaf = updated_tree.nodes[hd root.children]

    assert root.content == :empty
    assert leaf.content == %{x: 4}
  end
end
