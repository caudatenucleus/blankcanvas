// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'dropdown_item.dart';
import 'dropdown_element.dart';
import 'render_dropdown_button.dart';


class Dropdown<T> extends MultiChildRenderObjectWidget {
  Dropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder,
    this.tag,
  }) : super(children: _buildChildren(value, items, placeholder));

  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final Widget? placeholder;
  final String? tag;

  static List<Widget> _buildChildren<T>(
    T? value,
    List<DropdownItem<T>> items,
    Widget? placeholder,
  ) {
    if (value != null) {
      try {
        final item = items.firstWhere((i) => i.value == value);
        return [item.label];
      } catch (_) {}
    }
    if (placeholder != null) return [placeholder];
    return [];
  }

  @override
  DropdownElement<T> createElement() => DropdownElement<T>(this);

  @override
  RenderDropdownButton createRenderObject(BuildContext context) {
    return RenderDropdownButton();
  }
}
