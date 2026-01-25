// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'multi_select_element.dart';
import 'multi_select_chip.dart';
import 'render_multi_select.dart';


/// A chip-based multi-select input.
class MultiSelect<T> extends MultiChildRenderObjectWidget {
  MultiSelect({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.labelBuilder,
    this.placeholder = 'Select items...',
    this.maxSelections,
    this.tag,
  }) : super(children: _buildChildren(selectedValues, labelBuilder, onChanged));

  final List<T> options;
  final List<T> selectedValues;
  final void Function(List<T> selected) onChanged;
  final String Function(T item) labelBuilder;
  final String placeholder;
  final int? maxSelections;
  final String? tag;

  static List<Widget> _buildChildren<T>(
    List<T> selectedValues,
    String Function(T) labelBuilder,
    Function(List<T>) onChanged,
  ) {
    return selectedValues.map((item) {
      return MultiSelectChip(
        label: labelBuilder(item),
        onRemove: () {
          List<T> newValues = List.from(selectedValues)..remove(item);
          onChanged(newValues);
        },
      );
    }).toList();
  }

  @override
  MultiSelectElement<T> createElement() => MultiSelectElement<T>(this);

  @override
  RenderMultiSelect createRenderObject(BuildContext context) {
    return RenderMultiSelect(placeholder: placeholder);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMultiSelect renderObject,
  ) {
    renderObject.placeholder = placeholder;
  }
}
