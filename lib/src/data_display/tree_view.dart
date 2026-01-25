// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'tree_node.dart';
import 'tree_view_state.dart';


class TreeView<T> extends StatefulWidget {
  const TreeView({
    super.key,
    required this.nodes,
    required this.nodeBuilder,
    this.onNodeTap,
    this.tag,
  });

  final List<TreeNode<T>> nodes;
  final Widget Function(BuildContext context, T data) nodeBuilder;
  final ValueChanged<TreeNode<T>>? onNodeTap;
  final String? tag;

  @override
  State<TreeView<T>> createState() => TreeViewState<T>();
}
