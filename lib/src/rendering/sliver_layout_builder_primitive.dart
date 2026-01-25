// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderSliverLayoutBuilder - Viewport-aware sliver generation
// =============================================================================

typedef SliverLayoutWidgetBuilder =
    Widget Function(BuildContext context, SliverConstraints constraints);

class SliverLayoutBuilderPrimitive extends RenderObjectWidget {
  const SliverLayoutBuilderPrimitive({super.key, required this.builder});

  final SliverLayoutWidgetBuilder builder;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverLayoutBuilderPrimitive();
  }

  @override
  SliverLayoutBuilderElementPrimitive createElement() =>
      SliverLayoutBuilderElementPrimitive(this);
}

class SliverLayoutBuilderElementPrimitive extends RenderObjectElement {
  SliverLayoutBuilderElementPrimitive(
    SliverLayoutBuilderPrimitive super.widget,
  );

  Element? _child;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) visitor(_child!);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    renderObject.updateCallback(_layout);
  }

  @override
  void update(SliverLayoutBuilderPrimitive newWidget) {
    super.update(newWidget);
    renderObject.updateCallback(_layout);
    renderObject.markNeedsLayout();
  }

  @override
  void performRebuild() {
    renderObject.markNeedsLayout();
    super.performRebuild();
  }

  @override
  void unmount() {
    renderObject.updateCallback(null);
    super.unmount();
  }

  @override
  RenderSliverLayoutBuilderPrimitive get renderObject =>
      super.renderObject as RenderSliverLayoutBuilderPrimitive;

  void _layout(SliverConstraints constraints) {
    @pragma('vm:notify-debugger-on-exception')
    void layoutCallback() {
      final Widget built = (widget as SliverLayoutBuilderPrimitive).builder(
        this,
        constraints,
      );
      _child = updateChild(_child, built, slot);
    }

    owner!.buildScope(this, layoutCallback);
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    final RenderSliverLayoutBuilderPrimitive renderObject = this.renderObject;
    assert(renderObject.child == null);
    renderObject.child = child as RenderSliver;
    assert(renderObject.child == child);
  }

  @override
  void moveRenderObjectChild(
    RenderObject child,
    Object? oldSlot,
    Object? newSlot,
  ) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final RenderSliverLayoutBuilderPrimitive renderObject = this.renderObject;
    assert(renderObject.child == child);
    renderObject.child = null;
  }
}

typedef SliverLayoutCallback = void Function(SliverConstraints constraints);

class RenderSliverLayoutBuilderPrimitive extends RenderSliver
    with RenderObjectWithChildMixin<RenderSliver>, RenderSliverHelpers {
  SliverLayoutCallback? _callback;

  void updateCallback(SliverLayoutCallback? callback) {
    if (_callback == callback) return;
    _callback = callback;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (_callback != null) {
      invokeLayoutCallback<SliverConstraints>((SliverConstraints constraints) {
        assert(constraints == this.constraints);
        _callback!(constraints);
      });
    }
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      geometry = child!.geometry;
    } else {
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    // Children are positioned at the same origin.
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    if (child != null) {
      return child!.hitTest(
        result,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
    }
    return false;
  }
}
