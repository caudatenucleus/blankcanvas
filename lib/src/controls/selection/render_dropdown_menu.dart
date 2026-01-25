// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dropdown_item.dart';
import 'dropdown_parent_data.dart';


class RenderDropdownMenu<T> extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DropdownParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DropdownParentData> {
  RenderDropdownMenu({
    required List<DropdownItem<T>> items,
    required ValueChanged<T> onSelected,
  }) : _items = items,
       _onSelected = onSelected {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<DropdownItem<T>> _items;
  set items(List<DropdownItem<T>> value) {
    if (_items != value) {
      _items = value;
      markNeedsLayout();
    }
  }

  ValueChanged<T> _onSelected;
  set onSelected(ValueChanged<T> value) {
    _onSelected = value;
  }

  late TapGestureRecognizer _tap;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DropdownParentData) {
      child.parentData = DropdownParentData();
    }
  }

  @override
  void performLayout() {
    double width = constraints.maxWidth;
    double y = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(
        constraints.copyWith(minHeight: 0, maxHeight: double.infinity),
        parentUsesSize: true,
      );
      final DropdownParentData pd = child.parentData as DropdownParentData;
      pd.offset = Offset(8, y + (40 - child.size.height) / 2);

      y += math.max(child.size.height + 16, 40.0);

      child = childAfter(child);
    }

    size = Size(width, y);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Path path = Path()..addRect(offset & size);
    context.canvas.drawShadow(path, const Color(0x22000000), 4, true);
    context.canvas.drawRect(
      offset & size,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    defaultPaint(context, offset);
  }

  void _handleTapUp(TapUpDetails details) {
    double y = 0;
    RenderBox? child = firstChild;
    int index = 0;
    final localY = details.localPosition.dy;

    while (child != null && index < _items.length) {
      double rowHeight = math.max(child.size.height + 16, 40.0);
      // Only checking Y for loose hit testing on the row
      if (localY >= y && localY < y + rowHeight) {
        _onSelected(_items[index].value);
        return;
      }
      y += rowHeight;
      child = childAfter(child);
      index++;
    }
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
