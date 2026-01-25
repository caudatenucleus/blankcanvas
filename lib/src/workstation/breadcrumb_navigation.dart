// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// Hierarchical path primitive using lowest-level RenderObject APIs.
class BreadcrumbNavigation extends LeafRenderObjectWidget {
  const BreadcrumbNavigation({
    super.key,
    required this.items,
    this.onPathSelected,
  });

  final List<String> items;
  final ValueChanged<int>? onPathSelected;

  @override
  RenderBreadcrumbNavigation createRenderObject(BuildContext context) {
    return RenderBreadcrumbNavigation(items: items);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBreadcrumbNavigation renderObject,
  ) {
    renderObject.items = items;
  }
}

class RenderBreadcrumbNavigation extends RenderBox {
  RenderBreadcrumbNavigation({required List<String> items}) : _items = items;

  List<String> _items;
  set items(List<String> value) {
    if (_items == value) return;
    _items = value;
    markNeedsLayout();
  }

  // Placeholder for path selection logic
  // ValueChanged<int>? _onPathSelected;
  // set onPathSelected(ValueChanged<int>? value) => _onPathSelected = value;

  @override
  void performLayout() {
    final double width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 300.0;
    size = constraints.constrain(Size(width, 24));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // final canvas = context.canvas;
    // Paint segments with '/' separators (Placeholder)
  }
}
