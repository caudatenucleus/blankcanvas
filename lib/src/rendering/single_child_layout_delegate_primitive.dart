// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderCustomSingleChildLayout - Delegate-driven layout logic
// =============================================================================

abstract class SingleChildLayoutDelegatePrimitive {
  Size getSize(BoxConstraints constraints) => constraints.biggest;
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints;
  Offset getPositionForChild(Size size, Size childSize) => Offset.zero;
  bool shouldRelayout(
    covariant SingleChildLayoutDelegatePrimitive oldDelegate,
  ) => true;
}

class CustomSingleChildLayoutPrimitive extends SingleChildRenderObjectWidget {
  const CustomSingleChildLayoutPrimitive({
    super.key,
    required this.delegate,
    super.child,
  });
  final SingleChildLayoutDelegatePrimitive delegate;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomSingleChildLayoutPrimitive(delegate: delegate);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomSingleChildLayoutPrimitive renderObject,
  ) {
    renderObject.delegate = delegate;
  }
}

class RenderCustomSingleChildLayoutPrimitive extends RenderShiftedBox {
  RenderCustomSingleChildLayoutPrimitive({
    required SingleChildLayoutDelegatePrimitive delegate,
    RenderBox? child,
  }) : _delegate = delegate,
       super(child);

  SingleChildLayoutDelegatePrimitive _delegate;
  SingleChildLayoutDelegatePrimitive get delegate => _delegate;
  set delegate(SingleChildLayoutDelegatePrimitive value) {
    if (_delegate != value && value.shouldRelayout(_delegate)) {
      _delegate = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    size = _delegate.getSize(constraints);
    if (child != null) {
      child!.layout(
        _delegate.getConstraintsForChild(constraints),
        parentUsesSize: true,
      );
      final BoxParentData pd = child!.parentData! as BoxParentData;
      pd.offset = _delegate.getPositionForChild(size, child!.size);
    }
  }
}
