// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'tree_select_node.dart';
import 'tree_select_element.dart';
import 'render_tree_select.dart';


class TreeSelect<T> extends LeafRenderObjectWidget {
  const TreeSelect({
    super.key,
    required this.nodes,
    required this.onSelected,
    this.selectedValue,
    this.placeholder = 'Select...',
    this.multiSelect = false,
    this.selectedValues = const [],
    this.onMultiSelect,
    this.tag,
  });

  final List<TreeSelectNode<T>> nodes;
  final void Function(T value) onSelected;
  final T? selectedValue;
  final String placeholder;
  final bool multiSelect;
  final List<T> selectedValues;
  final void Function(List<T> values)? onMultiSelect;
  final String? tag;

  @override
  TreeSelectElement<T> createElement() => TreeSelectElement<T>(this);

  @override
  RenderTreeSelect<T> createRenderObject(BuildContext context) {
    return RenderTreeSelect<T>(
      placeholder: placeholder,
      selectedValue: selectedValue,
      selectedValues: selectedValues,
      multiSelect: multiSelect,
      nodes: nodes,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTreeSelect<T> renderObject,
  ) {
    renderObject
      ..placeholder = placeholder
      ..selectedValue = selectedValue
      ..selectedValues = selectedValues
      ..multiSelect = multiSelect
      ..nodes = nodes;
  }
}
