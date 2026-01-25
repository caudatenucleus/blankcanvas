// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderIgnorePointer - Global hit-test bypass engine
// =============================================================================

class IgnorePointerPrimitive extends SingleChildRenderObjectWidget {
  const IgnorePointerPrimitive({super.key, this.ignoring = true, super.child});
  final bool ignoring;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderIgnorePointerPrimitive(ignoring: ignoring);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderIgnorePointerPrimitive renderObject,
  ) {
    renderObject.ignoring = ignoring;
  }
}

class RenderIgnorePointerPrimitive extends RenderProxyBox {
  RenderIgnorePointerPrimitive({bool ignoring = true, RenderBox? child})
    : _ignoring = ignoring,
      super(child);

  bool _ignoring;
  bool get ignoring => _ignoring;
  set ignoring(bool value) {
    if (_ignoring != value) {
      _ignoring = value;
      markNeedsSemanticsUpdate();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_ignoring) return false;
    return super.hitTest(result, position: position);
  }
}
