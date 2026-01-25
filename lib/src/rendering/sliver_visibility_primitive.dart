// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverVisibility - Lifecycle-aware sliver culling
// =============================================================================

class SliverVisibilityPrimitive extends SingleChildRenderObjectWidget {
  const SliverVisibilityPrimitive({
    super.key,
    required this.visible,
    this.maintainState = false,
    this.maintainAnimation = false,
    this.maintainSize = false,
    this.maintainSemantics = false,
    this.maintainInteractivity = false,
    super.child,
  });

  final bool visible;
  final bool maintainState;
  final bool maintainAnimation;
  final bool maintainSize;
  final bool maintainSemantics;
  final bool maintainInteractivity;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverVisibilityPrimitive(
      visible: visible,
      maintainSemantics: maintainSemantics,
      maintainInteractivity: maintainInteractivity,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverVisibilityPrimitive renderObject,
  ) {
    renderObject
      ..visible = visible
      ..maintainSemantics = maintainSemantics
      ..maintainInteractivity = maintainInteractivity;
  }
}

class RenderSliverVisibilityPrimitive extends RenderProxySliver {
  RenderSliverVisibilityPrimitive({
    required bool visible,
    bool maintainSemantics = false,
    bool maintainInteractivity = false,
  }) : _visible = visible,
       _maintainSemantics = maintainSemantics,
       _maintainInteractivity = maintainInteractivity;

  bool _visible;
  bool get visible => _visible;
  set visible(bool value) {
    if (_visible != value) {
      _visible = value;
      markNeedsLayout();
    }
  }

  bool _maintainSemantics;
  bool get maintainSemantics => _maintainSemantics;
  set maintainSemantics(bool value) {
    if (_maintainSemantics != value) {
      _maintainSemantics = value;
      markNeedsSemanticsUpdate();
    }
  }

  bool _maintainInteractivity;
  bool get maintainInteractivity => _maintainInteractivity;
  set maintainInteractivity(bool value) {
    if (_maintainInteractivity != value) {
      _maintainInteractivity = value;
    }
  }

  @override
  void performLayout() {
    if (!_visible) {
      geometry = SliverGeometry.zero;
      return;
    }
    super.performLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_visible) {
      super.paint(context, offset);
    }
  }

  @override
  bool hitTest(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (!_visible && !_maintainInteractivity) {
      return false;
    }
    return super.hitTest(
      result,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
    );
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (_visible || _maintainSemantics) {
      super.visitChildrenForSemantics(visitor);
    }
  }
}
