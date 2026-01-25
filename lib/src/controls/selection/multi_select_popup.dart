// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_multi_select_popup.dart';

class MultiSelectPopup<T> extends LeafRenderObjectWidget {
  const MultiSelectPopup({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.labelBuilder,
    required this.onSelect,
  });

  final List<T> options;
  final List<T> selectedValues;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelect;

  @override
  RenderMultiSelectPopup<T> createRenderObject(BuildContext context) {
    return RenderMultiSelectPopup<T>(
      options: options,
      selectedValues: selectedValues,
      labelBuilder: labelBuilder,
      onSelect: onSelect,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMultiSelectPopup<T> renderObject,
  ) {
    renderObject
      ..options = options
      ..selectedValues = selectedValues
      ..labelBuilder = labelBuilder
      ..onSelect = onSelect;
  }
}
