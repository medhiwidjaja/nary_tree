defmodule NaryTreeTest do
  use ExUnit.Case
  doctest NaryTree

  setup_all do
    branch1 = NaryTree.Node.new(1, "Branch node 1")
    branch2 = NaryTree.Node.new(2, "Branch node 2")
    leaf1 = NaryTree.Node.new(3, "Leaf node 1")
    leaf2 = NaryTree.Node.new(4, "Leaf node 2")
    complex_tree = (NaryTree.new(NaryTree.Node.new(5, "Root node"))
      |> NaryTree.add_child(branch1)
      |> NaryTree.add_child(branch2)
      |> NaryTree.add_child(leaf1, branch1.id)
      |> NaryTree.add_child(leaf2, branch1.id))

    [
      simple_tree: NaryTree.new(NaryTree.Node.new(6, "Root node"))
        |> NaryTree.add_child(NaryTree.Node.new(7, "Leaf node 1"))
        |> NaryTree.add_child(NaryTree.Node.new(8, "Leaf node 2")),

      big_tree: complex_tree,
      branch1: branch1,
      branch2: branch2,
      leaves: [leaf1.id, leaf2.id]
    ]
  end

  test "updating each leaf will not update non-leaf nodes", context do

    updated_tree = NaryTree.each_leaf(context[:simple_tree], fn(_) -> %{x: 4} end)
    root = updated_tree.nodes[updated_tree.root]
    leaf = updated_tree.nodes[hd root.children]

    assert root.content == :empty
    assert leaf.content == %{x: 4}
  end

  test "moving nodes from one parent node to another", context do
    branch1 = NaryTree.get context[:big_tree], context[:branch1].id
    branch2 = NaryTree.get context[:big_tree], context[:branch2].id
    assert branch1.children == context[:leaves]
    assert branch2.children == []

    updated_tree = NaryTree.move_nodes(context[:big_tree], context[:leaves], branch2.id)
    updated_branch1 = NaryTree.get updated_tree, context[:branch1].id
    updated_branch2 = NaryTree.get updated_tree, context[:branch2].id

    assert updated_branch1.children == []
    assert updated_branch2.children == context[:leaves]
  end


end
