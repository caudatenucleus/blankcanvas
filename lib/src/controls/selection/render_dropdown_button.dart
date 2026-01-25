// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dropdown_parent_data.dart';


class RenderDropdownButton extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DropdownParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DropdownParentData> {
  RenderDropdownButton() {
    _tap = TapGestureRecognizer()..onTap = () => onTap?.call();
  }

  late TapGestureRecognizer _tap;
  VoidCallback? onTap;

  bool _isOpen = false;
  set isOpen(bool value) {
    if (_isOpen != value) {
      _isOpen = value;
      markNeedsPaint();
    }
  }

  LayerLink? layerLink;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DropdownParentData) {
      child.parentData = DropdownParentData();
    }
  }

  @override
  void performLayout() {
    RenderBox? child = firstChild;
    double width = constraints.minWidth;
    double height = 0;

    if (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      width = child.size.width + 24;
      height = child.size.height + 16;
    } else {
      width = 100;
      height = 40;
    }

    width = constraints.constrainWidth(width);
    height = constraints.constrainHeight(height);

    if (child != null) {
      final DropdownParentData pd = child.parentData as DropdownParentData;
      pd.offset = Offset(8, (height - child.size.height) / 2);
    }

    size = Size(width, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint bgPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.fill;

    final Rect rect = offset & size;
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      bgPaint,
    );

    if (layerLink != null) {
      context.pushLayer(LeaderLayer(link: layerLink!, offset: Offset.zero), (
        context,
        offset,
      ) {
        RenderBox? child = firstChild;
        if (child != null) {
          final DropdownParentData pd = child.parentData as DropdownParentData;
          context.paintChild(child, offset + pd.offset);
        }
      }, offset);
    } else {
      RenderBox? child = firstChild;
      if (child != null) {
        final DropdownParentData pd = child.parentData as DropdownParentData;
        context.paintChild(child, offset + pd.offset);
      }
    }

    final Paint arrowPaint = Paint()
      ..color = const Color(0xFF666666)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double arrowSize = 6;
    final double arrowX = offset.dx + size.width - 16;
    final double arrowY = offset.dy + size.height / 2;

    final Path arrowPath = Path();
    if (_isOpen) {
      arrowPath.moveTo(arrowX - arrowSize / 2, arrowY + arrowSize / 4);
      arrowPath.lineTo(arrowX, arrowY - arrowSize / 4);
      arrowPath.lineTo(arrowX + arrowSize / 2, arrowY + arrowSize / 4);
    } else {
      arrowPath.moveTo(arrowX - arrowSize / 2, arrowY - arrowSize / 4);
      arrowPath.lineTo(arrowX, arrowY + arrowSize / 4);
      arrowPath.lineTo(arrowX + arrowSize / 2, arrowY - arrowSize / 4);
    }
    context.canvas.drawPath(arrowPath, arrowPaint);
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
