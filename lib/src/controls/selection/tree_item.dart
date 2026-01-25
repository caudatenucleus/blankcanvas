// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'tree_select_node.dart';

class TreeItem<T> {
  final TreeSelectNode<T> node;
  final int depth;
  TreeItem(this.node, this.depth);
}
