// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_auto_complete_list.dart';

class AutoCompleteList<T> extends MultiChildRenderObjectWidget {
  const AutoCompleteList({
    super.key,
    required super.children,
    required this.onItemTap,
    required this.onHover,
  });

  final ValueChanged<int> onItemTap;
  final ValueChanged<int> onHover;

  @override
  RenderAutoCompleteList createRenderObject(BuildContext context) {
    return RenderAutoCompleteList(onItemTap: onItemTap, onHover: onHover);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAutoCompleteList renderObject,
  ) {
    renderObject.onItemTap = onItemTap;
    renderObject.onHover = onHover;
  }
}
