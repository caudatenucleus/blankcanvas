// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'tree_select_node.dart';
import 'render_tree_select_popup.dart';


class TreeSelectPopup<T> extends LeafRenderObjectWidget {
  const TreeSelectPopup({
    super.key,
    required this.nodes,
    required this.selectedValues,
    required this.selectedValue,
    required this.multiSelect,
    required this.onNodeTap,
    required this.onExpandTap,
  });

  final List<TreeSelectNode<T>> nodes;
  final List<T> selectedValues;
  final T? selectedValue;
  final bool multiSelect;
  final ValueChanged<TreeSelectNode<T>> onNodeTap;
  final ValueChanged<TreeSelectNode<T>> onExpandTap;

  @override
  RenderTreeSelectPopup<T> createRenderObject(BuildContext context) {
    return RenderTreeSelectPopup<T>(
      nodes: nodes,
      selectedValues: selectedValues,
      selectedValue: selectedValue,
      multiSelect: multiSelect,
      onNodeTap: onNodeTap,
      onExpandTap: onExpandTap,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTreeSelectPopup<T> renderObject,
  ) {
    renderObject
      ..nodes = nodes
      ..selectedValues = selectedValues
      ..selectedValue = selectedValue
      ..multiSelect = multiSelect
      ..onNodeTap = onNodeTap
      ..onExpandTap = onExpandTap;
  }
}
