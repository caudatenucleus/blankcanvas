// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';
import 'tree_node.dart';
import 'tree_view.dart';
import 'flat_node.dart';
import 'tree_view_layout.dart';
import 'tree_item_widget.dart';


class TreeViewState<T> extends State<TreeView<T>> {
  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTreeView(widget.tag);

    final status = TreeControlStatus();
    final decoration =
        customization?.decoration(status) ?? const BoxDecoration();

    final List<FlatNode<T>> flatNodes = [];
    void flatten(TreeNode<T> node, int depth) {
      flatNodes.add(FlatNode(node: node, depth: depth));
      if (node.isExpanded) {
        for (final child in node.children) {
          flatten(child, depth + 1);
        }
      }
    }

    for (final node in widget.nodes) {
      flatten(node, 0);
    }

    return TreeViewLayout(
      decoration: decoration,
      children: flatNodes.map((flatNode) {
        return TreeItemWidget<T>(
          key: ObjectKey(flatNode.node),
          node: flatNode.node,
          depth: flatNode.depth,
          content: widget.nodeBuilder(context, flatNode.node.data),
          onTap: () => widget.onNodeTap?.call(flatNode.node),
          onToggle: () {
            setState(() {
              flatNode.node.isExpanded = !flatNode.node.isExpanded;
            });
          },
          customization:
              customization?.itemCustomization ??
              TreeItemCustomization.simple(),
        );
      }).toList(),
    );
  }
}
