# nary_tree

NaryTree is a pure Elixir implementation of the generic tree data structure. NaryTree implements a data structure for an n-ary tree in which each node has zero or more children. A node in a tree can have arbitrary number of children and depth. Trees are unbalanced and children unordered.

It provides a node-based model to store named nodes in the tree, and provides simple APIs to access, modify and traverse the structure.

Currently only depth-first tree-traversal method is supported.

The library implements Enumerable protocol to allow access to the tree using standard Enum functions (map, reduce, count, etc)

NaryTree supports importing from, and exporting to Map.

This is a MIT licensed open source project, and is hosted at github.com/medhiwidjaja/nary_tree, and is available as a standard Hex package from hex.pm.
