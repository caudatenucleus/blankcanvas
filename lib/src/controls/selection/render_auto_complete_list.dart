// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'auto_complete_list_parent_data.dart';


class RenderAutoCompleteList extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AutoCompleteListParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AutoCompleteListParentData> {
  RenderAutoCompleteList({
    required ValueChanged<int> onItemTap,
    required ValueChanged<int> onHover,
  }) : _onItemTap = onItemTap,
       _onHover = onHover;

  ValueChanged<int> _onItemTap;
  set onItemTap(ValueChanged<int> val) => _onItemTap = val;

  ValueChanged<int> _onHover;
  set onHover(ValueChanged<int> val) => _onHover = val;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AutoCompleteListParentData) {
      child.parentData = AutoCompleteListParentData();
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
      final AutoCompleteListParentData pd =
          child.parentData as AutoCompleteListParentData;
      pd.offset = Offset(0, y);
      y += child.size.height;
      child = childAfter(child);
    }
    size = Size(width, y);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint shadow/bg
    final Path path = Path()..addRect(offset & size);
    context.canvas.drawShadow(path, const Color(0x22000000), 4, true);
    context.canvas.drawRect(
      offset & size,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    defaultPaint(context, offset);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _handleTap(event.localPosition);
    } else if (event is PointerHoverEvent) {
      _handleHover(event.localPosition);
    }
  }

  void _handleTap(Offset local) {
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final AutoCompleteListParentData pd =
          child.parentData as AutoCompleteListParentData;
      final Rect rect = pd.offset & child.size;
      if (rect.contains(local)) {
        _onItemTap(index);
        return;
      }
      child = childAfter(child);
      index++;
    }
  }

  void _handleHover(Offset local) {
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final AutoCompleteListParentData pd =
          child.parentData as AutoCompleteListParentData;
      final Rect rect = pd.offset & child.size;
      if (rect.contains(local)) {
        _onHover(index);
        return;
      }
      child = childAfter(child);
      index++;
    }
  }
}
