// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderAbsorbPointer - Hit-test cancellation engine
// =============================================================================

class AbsorbPointerPrimitive extends SingleChildRenderObjectWidget {
  const AbsorbPointerPrimitive({super.key, this.absorbing = true, super.child});
  final bool absorbing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAbsorbPointerPrimitive(absorbing: absorbing);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAbsorbPointerPrimitive renderObject,
  ) {
    renderObject.absorbing = absorbing;
  }
}

class RenderAbsorbPointerPrimitive extends RenderProxyBox {
  RenderAbsorbPointerPrimitive({bool absorbing = true, RenderBox? child})
    : _absorbing = absorbing,
      super(child);

  bool _absorbing;
  bool get absorbing => _absorbing;
  set absorbing(bool value) {
    if (_absorbing != value) {
      _absorbing = value;
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_absorbing) {
      // Absorb the hit test - return true to indicate we handled it, but don't pass to children
      return size.contains(position);
    }
    return super.hitTest(result, position: position);
  }
}
