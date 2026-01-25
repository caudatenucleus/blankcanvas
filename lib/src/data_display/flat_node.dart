// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'tree_node.dart';

class FlatNode<T> {
  FlatNode({required this.node, required this.depth});
  final TreeNode<T> node;
  final int depth;
}
