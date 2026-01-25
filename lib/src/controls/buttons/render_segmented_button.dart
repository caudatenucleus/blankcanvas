// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';


class RenderSegmentedButton extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SegmentedButtonLayoutParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          SegmentedButtonLayoutParentData
        > {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SegmentedButtonLayoutParentData) {
      child.parentData = SegmentedButtonLayoutParentData();
    }
  }

  @override
  void performLayout() {
    double width = 0;
    double height = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints.loose(constraints.biggest),
        parentUsesSize: true,
      );
      width += child.size.width;
      if (child.size.height > height) height = child.size.height;
      child = childAfter(child);
    }

    // Position
    double x = 0;
    child = firstChild;
    while (child != null) {
      final pd = child.parentData as SegmentedButtonLayoutParentData;
      pd.offset = Offset(x, (height - child.size.height) / 2);
      x += child.size.width;
      child = childAfter(child);
    }

    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Round border clip
    final Rect bounds = offset & size;
    final RRect rrect = RRect.fromRectAndRadius(bounds, Radius.circular(8));

    context.pushClipRRect(needsCompositing, offset, bounds, rrect, (ctx, off) {
      // Bg
      ctx.canvas.drawRect(off & size, Paint()..color = const Color(0xFFFFFFFF));

      defaultPaint(ctx, off);

      // Border
      ctx.canvas.drawRRect(
        RRect.fromRectAndRadius(off & size, Radius.circular(8)),
        Paint()
          ..color = const Color(0xFFBDBDBD)
          ..style = PaintingStyle.stroke,
      );

      // Dividers
      RenderBox? child = firstChild;
      while (child != null) {
        final next = childAfter(child);
        if (next != null) {
          final pd = child.parentData as SegmentedButtonLayoutParentData;
          double dx = off.dx + pd.offset.dx + child.size.width;
          ctx.canvas.drawLine(
            Offset(dx, off.dy),
            Offset(dx, off.dy + size.height),
            Paint()..color = const Color(0xFFBDBDBD),
          );
        }
        child = next;
      }
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}

class SegmentedButtonLayoutParentData
    extends ContainerBoxParentData<RenderBox> {}
