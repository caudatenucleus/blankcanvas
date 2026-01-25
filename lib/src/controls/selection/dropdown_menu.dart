// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'dropdown_item.dart';
import 'render_dropdown_menu.dart';


class DropdownMenu<T> extends MultiChildRenderObjectWidget {
  DropdownMenu({super.key, required this.items, required this.onSelected})
    : super(children: items.map((i) => i.label).toList());

  final List<DropdownItem<T>> items;
  final ValueChanged<T> onSelected;

  @override
  RenderDropdownMenu<T> createRenderObject(BuildContext context) {
    return RenderDropdownMenu<T>(items: items, onSelected: onSelected);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDropdownMenu<T> renderObject,
  ) {
    renderObject.items = items;
    renderObject.onSelected = onSelected;
  }
}
