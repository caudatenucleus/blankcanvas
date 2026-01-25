// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'tree_view_layout_parent_data.dart';


class RenderTreeViewLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TreeViewLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TreeViewLayoutParentData> {
  RenderTreeViewLayout({required Decoration decoration})
    : _decoration = decoration {
    _drag = PanGestureRecognizer()..onUpdate = _handleDragUpdate;
  }

  Decoration _decoration;
  set decoration(Decoration val) {
    if (_decoration != val) {
      _decoration = val;
      markNeedsPaint();
    }
  }

  late PanGestureRecognizer _drag;
  double _scrollY = 0;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TreeViewLayoutParentData) {
      child.parentData = TreeViewLayoutParentData();
    }
  }

  @override
  void performLayout() {
    double y = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints(
          maxWidth: constraints.maxWidth,
          minWidth: constraints.maxWidth,
        ),
        parentUsesSize: true,
      );
      final pd = child.parentData as TreeViewLayoutParentData;
      pd.offset = Offset(0, y);
      y += child.size.height;
      child = childAfter(child);
    }
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint();
    if (_decoration is BoxDecoration) {
      final d = _decoration as BoxDecoration;
      paint.color = d.color ?? const Color(0x00000000);
      if (d.borderRadius != null) {
        context.canvas.drawRRect(
          d.borderRadius!.resolve(TextDirection.ltr).toRRect(rect),
          paint,
        );
      } else {
        context.canvas.drawRect(rect, paint);
      }
    }

    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      ctx,
      off,
    ) {
      RenderBox? child = firstChild;
      while (child != null) {
        final pd = child.parentData as TreeViewLayoutParentData;
        final double childY = pd.offset.dy - _scrollY;

        if (childY + child.size.height > 0 && childY < size.height) {
          ctx.paintChild(child, off + Offset(0, childY));
        }
        child = childAfter(child);
      }
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    double contentHeight = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      contentHeight += child.size.height;
      child = childAfter(child);
    }

    _scrollY -= details.delta.dy;
    _scrollY = _scrollY.clamp(0.0, math.max(0.0, contentHeight - size.height));
    markNeedsPaint();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(
      result,
      position: position + Offset(0, _scrollY),
    );
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }
}
