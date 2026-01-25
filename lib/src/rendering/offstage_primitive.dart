// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderOffstage - Layout-only dormant engine
// =============================================================================

class OffstagePrimitive extends SingleChildRenderObjectWidget {
  const OffstagePrimitive({super.key, this.offstage = true, super.child});
  final bool offstage;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderOffstagePrimitive(offstage: offstage);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOffstagePrimitive renderObject,
  ) {
    renderObject.offstage = offstage;
  }
}

class RenderOffstagePrimitive extends RenderProxyBox {
  RenderOffstagePrimitive({bool offstage = true, RenderBox? child})
    : _offstage = offstage,
      super(child);

  bool _offstage;
  bool get offstage => _offstage;
  set offstage(bool value) {
    if (_offstage != value) {
      _offstage = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = constraints.smallest;
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (_offstage) return false;
    return super.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_offstage) return;
    super.paint(context, offset);
  }
}
