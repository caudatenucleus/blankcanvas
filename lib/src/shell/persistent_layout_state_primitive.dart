// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'layout_state_data.dart';
import 'render_persistent_layout_state.dart';


class PersistentLayoutStatePrimitive extends LeafRenderObjectWidget {
  const PersistentLayoutStatePrimitive({
    super.key,
    required this.elements,
    this.borderColor = const Color(0xFF007AFF),
    this.labelColor = const Color(0xFFFFFFFF),
    this.showLabels = true,
  });

  final List<LayoutStateData> elements;
  final Color borderColor;
  final Color labelColor;
  final bool showLabels;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPersistentLayoutState(
      elements: elements,
      borderColor: borderColor,
      labelColor: labelColor,
      showLabels: showLabels,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPersistentLayoutState renderObject,
  ) {
    renderObject
      ..elements = elements
      ..borderColor = borderColor
      ..labelColor = labelColor
      ..showLabels = showLabels;
  }
}
