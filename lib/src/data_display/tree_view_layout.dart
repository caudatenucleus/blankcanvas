// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'render_tree_view_layout.dart';


class TreeViewLayout extends MultiChildRenderObjectWidget {
  const TreeViewLayout({
    super.key,
    required this.decoration,
    required super.children,
  });
  final Decoration decoration;

  @override
  RenderTreeViewLayout createRenderObject(BuildContext context) {
    return RenderTreeViewLayout(decoration: decoration);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTreeViewLayout renderObject,
  ) {
    renderObject.decoration = decoration;
  }
}
