// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.



/// A node in the tree.
class TreeNode<T> {
  TreeNode({
    required this.data,
    this.children = const [],
    this.isExpanded = false,
  });

  final T data;
  final List<TreeNode<T>> children;
  bool isExpanded;
}
