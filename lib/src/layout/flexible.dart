// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'flex.dart';
import 'package:flutter/widgets.dart' hide Flexible, Flex;

/// A widget that controls how a child of a [Row], [Column], or [Flex] flexes.
class Flexible extends ParentDataWidget<FlexParentData> {
  const Flexible({
    super.key,
    this.flex = 1,
    this.fit = FlexFit.loose,
    required super.child,
  });

  final int flex;
  final FlexFit fit;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is FlexParentData);
    final FlexParentData parentData =
        renderObject.parentData! as FlexParentData;
    bool needsLayout = false;

    if (parentData.flex != flex) {
      parentData.flex = flex;
      needsLayout = true;
    }

    if (parentData.fit != fit) {
      parentData.fit = fit;
      needsLayout = true;
    }

    if (needsLayout) {
      final Object? targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => Flex;
}

/// A widget that expands a child of a [Row], [Column], or [Flex]
