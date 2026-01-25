// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderPadding - Inset-based layout logic
// =============================================================================

class PaddingPrimitive extends SingleChildRenderObjectWidget {
  const PaddingPrimitive({super.key, required this.padding, super.child});
  final EdgeInsetsGeometry padding;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPaddingPrimitive(
      padding: padding.resolve(Directionality.of(context)),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPaddingPrimitive renderObject,
  ) {
    renderObject.padding = padding.resolve(Directionality.of(context));
  }
}

class RenderPaddingPrimitive extends RenderShiftedBox {
  RenderPaddingPrimitive({
    EdgeInsets padding = EdgeInsets.zero,
    RenderBox? child,
  }) : _padding = padding,
       super(child);

  EdgeInsets _padding;
  EdgeInsets get padding => _padding;
  set padding(EdgeInsets value) {
    if (_padding != value) {
      _padding = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.constrain(
        Size(_padding.left + _padding.right, _padding.top + _padding.bottom),
      );
      return;
    }

    final innerConstraints = constraints.deflate(_padding);
    child!.layout(innerConstraints, parentUsesSize: true);
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    childParentData.offset = Offset(_padding.left, _padding.top);
    size = constraints.constrain(
      Size(
        _padding.left + child!.size.width + _padding.right,
        _padding.top + child!.size.height + _padding.bottom,
      ),
    );
  }
}
