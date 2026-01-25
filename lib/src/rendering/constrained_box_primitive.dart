// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderConstrainedBox - Constraint-imposing layout logic
// =============================================================================

class ConstrainedBoxPrimitive extends SingleChildRenderObjectWidget {
  const ConstrainedBoxPrimitive({
    super.key,
    required this.additionalConstraints,
    super.child,
  });
  final BoxConstraints additionalConstraints;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderConstrainedBoxPrimitive(
      additionalConstraints: additionalConstraints,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConstrainedBoxPrimitive renderObject,
  ) {
    renderObject.additionalConstraints = additionalConstraints;
  }
}

class RenderConstrainedBoxPrimitive extends RenderProxyBox {
  RenderConstrainedBoxPrimitive({
    BoxConstraints additionalConstraints = const BoxConstraints(),
    RenderBox? child,
  }) : _additionalConstraints = additionalConstraints,
       super(child);

  BoxConstraints _additionalConstraints;
  BoxConstraints get additionalConstraints => _additionalConstraints;
  set additionalConstraints(BoxConstraints value) {
    if (_additionalConstraints != value) {
      _additionalConstraints = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(
        _additionalConstraints.enforce(constraints),
        parentUsesSize: true,
      );
      size = child!.size;
    } else {
      size = _additionalConstraints.enforce(constraints).constrain(Size.zero);
    }
  }
}
