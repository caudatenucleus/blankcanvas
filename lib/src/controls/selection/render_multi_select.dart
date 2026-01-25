// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'multi_select_parent_data.dart';


class RenderMultiSelect extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiSelectParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiSelectParentData> {
  RenderMultiSelect({required String placeholder})
    : _placeholder = placeholder {
    _tap = TapGestureRecognizer()..onTap = () => onTap?.call();
  }

  String _placeholder;
  set placeholder(String value) {
    if (_placeholder != value) {
      _placeholder = value;
      markNeedsPaint();
    }
  }

  LayerLink? layerLink;
  VoidCallback? onTap;
  late TapGestureRecognizer _tap;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiSelectParentData) {
      child.parentData = MultiSelectParentData();
    }
  }

  @override
  void performLayout() {
    // Wrap layout
    double width = constraints.maxWidth;
    double x = 8;
    double y = 8;
    double rowHeight = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(BoxConstraints(maxWidth: width - 16), parentUsesSize: true);

      if (x + child.size.width > width - 30) {
        // -30 for arrow space and padding
        x = 8;
        y += rowHeight + 4;
        rowHeight = 0;
      }

      final MultiSelectParentData pd =
          child.parentData as MultiSelectParentData;
      pd.offset = Offset(x, y);

      x += child.size.width + 4;
      rowHeight = math.max(rowHeight, child.size.height);

      child = childAfter(child);
    }

    y += rowHeight + 8;

    size = constraints.constrain(Size(width, math.max(y, 44.0)));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Bg
    final Rect rect = offset & size;
    final Paint bg = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    final Paint border = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      bg,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      border,
    );

    // Placeholder if empty
    if (firstChild == null) {
      final tp = TextPainter(
        text: TextSpan(
          text: _placeholder,
          style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        context.canvas,
        offset + Offset(12, (size.height - tp.height) / 2),
      );
    }

    // Chips (children)
    if (layerLink != null) {
      // If we used LeaderLayer, we wrap painting.
      context.pushLayer(LeaderLayer(link: layerLink!, offset: Offset.zero), (
        ctx,
        off,
      ) {
        defaultPaint(ctx, off);
      }, offset);
    } else {
      defaultPaint(context, offset);
    }

    // Arrow
    final double arrowX = offset.dx + size.width - 16;
    final double arrowY = offset.dy + size.height / 2;
    final Paint arrowPaint = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.moveTo(arrowX - 4, arrowY - 2);
    path.lineTo(arrowX, arrowY + 2);
    path.lineTo(arrowX + 4, arrowY - 2);
    context.canvas.drawPath(path, arrowPaint);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }
}

// Popup