// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/theme/customization.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';
import 'tree_node.dart';
import 'toggle_icon_widget.dart';
import 'render_tree_item.dart';


class TreeItemWidget<T> extends MultiChildRenderObjectWidget {
  TreeItemWidget({
    super.key,
    required this.node,
    required this.depth,
    required Widget content,
    required this.onTap,
    required this.onToggle,
    required this.customization,
  }) : super(
         children: [
           content,
           if (node.children.isNotEmpty)
             ToggleIconWidget(
               isExpanded: node.isExpanded,
               customization: customization,
             ),
         ],
       );

  final TreeNode<T> node;
  final int depth;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final TreeItemCustomization customization;

  @override
  RenderTreeItem createRenderObject(BuildContext context) {
    return RenderTreeItem(
      depth: depth,
      indent: customization.indent ?? 20.0,
      padding:
          customization.padding ??
          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration:
          customization.decoration(
                TreeItemControlStatus()
                  ..enabled = 1.0
                  ..hovered = 0.0
                  ..selected = 0.0
                  ..expanded = node.isExpanded ? 1.0 : 0.0,
              )
              as BoxDecoration,
      onTap: onTap,
      onToggle: onToggle,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTreeItem renderObject) {
    renderObject
      ..depth = depth
      ..indent = customization.indent ?? 20.0
      ..padding =
          customization.padding ??
          const EdgeInsets.symmetric(vertical: 4, horizontal: 8)
      ..decoration =
          customization.decoration(
                TreeItemControlStatus()
                  ..enabled = 1.0
                  ..hovered = 0.0
                  ..selected = 0.0
                  ..expanded = node.isExpanded ? 1.0 : 0.0,
              )
              as BoxDecoration
      ..onTap = onTap
      ..onToggle = onToggle;
  }
}
