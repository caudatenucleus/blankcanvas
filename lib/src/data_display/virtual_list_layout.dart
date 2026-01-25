// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_virtual_list.dart';


class VirtualListLayout extends MultiChildRenderObjectWidget {
  const VirtualListLayout({
    super.key,
    required this.scrollDirection,
    required this.padding,
    this.itemExtent,
    this.controller,
    required super.children,
  });

  final Axis scrollDirection;
  final EdgeInsets padding;
  final double? itemExtent;
  final ScrollController? controller;

  @override
  RenderVirtualList createRenderObject(BuildContext context) {
    return RenderVirtualList(
      scrollDirection: scrollDirection,
      padding: padding,
      itemExtent: itemExtent,
      controller: controller,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderVirtualList renderObject,
  ) {
    renderObject
      ..scrollDirection = scrollDirection
      ..padding = padding
      ..itemExtent = itemExtent
      ..controller = controller;
  }
}
