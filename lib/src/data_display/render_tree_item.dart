// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'tree_item_parent_data.dart';


class RenderTreeItem extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TreeItemParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TreeItemParentData> {
  RenderTreeItem({
    required int depth,
    required double indent,
    required EdgeInsetsGeometry padding,
    required Decoration decoration,
    required this.onTap,
    required this.onToggle,
  }) : _depth = depth,
       _indent = indent,
       _padding = padding,
       _decoration = decoration {
    _tap = TapGestureRecognizer()..onTap = _handleTap;
  }

  int _depth;
  set depth(int value) {
    if (_depth != value) {
      _depth = value;
      markNeedsLayout();
    }
  }

  double _indent;
  set indent(double value) {
    if (_indent != value) {
      _indent = value;
      markNeedsLayout();
    }
  }

  EdgeInsetsGeometry _padding;
  set padding(EdgeInsetsGeometry value) {
    if (_padding != value) {
      _padding = value;
      markNeedsLayout();
    }
  }

  Decoration _decoration;
  set decoration(Decoration value) {
    if (_decoration != value) {
      _decoration = value;
      markNeedsPaint();
    }
  }

  VoidCallback onTap;
  VoidCallback onToggle;

  late TapGestureRecognizer _tap;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TreeItemParentData) {
      child.parentData = TreeItemParentData();
    }
  }

  @override
  void performLayout() {
    final resolvedPadding = _padding.resolve(TextDirection.ltr);
    final double leftOffset = _depth * _indent + resolvedPadding.left;
    double maxChildHeight = 0;

    RenderBox? content = firstChild;
    RenderBox? toggle = content != null ? childAfter(content) : null;

    if (toggle != null) {
      toggle.layout(constraints.loosen(), parentUsesSize: true);
      final toggleParentData = toggle.parentData! as TreeItemParentData;
      toggleParentData.offset = Offset(leftOffset, resolvedPadding.top);
      maxChildHeight = toggle.size.height;
    }

    if (content != null) {
      final double contentLeft =
          leftOffset + (toggle != null ? toggle.size.width + 8 : 20);
      double availWidth = math.max(
        0,
        constraints.maxWidth - contentLeft - resolvedPadding.right,
      );

      content.layout(
        BoxConstraints(minWidth: 0, maxWidth: availWidth),
        parentUsesSize: true,
      );

      final contentParentData = content.parentData! as TreeItemParentData;
      contentParentData.offset = Offset(contentLeft, resolvedPadding.top);

      maxChildHeight = math.max(maxChildHeight, content.size.height);
    }

    size = constraints.constrain(
      Size(constraints.maxWidth, maxChildHeight + resolvedPadding.vertical),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint();
    if (_decoration is BoxDecoration) {
      final boxDecoration = _decoration as BoxDecoration;
      paint.color = boxDecoration.color ?? const Color(0x00000000);
      if (boxDecoration.borderRadius != null) {
        context.canvas.drawRRect(
          boxDecoration.borderRadius!.resolve(TextDirection.ltr).toRRect(rect),
          paint,
        );
      } else {
        context.canvas.drawRect(rect, paint);
      }
    }
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      // Logic for toggle vs content hit test
      RenderBox? content = firstChild;
      RenderBox? toggle = content != null ? childAfter(content) : null;

      if (toggle != null) {
        final toggleParentData = toggle.parentData! as TreeItemParentData;
        if ((toggleParentData.offset & toggle.size).contains(
          event.localPosition,
        )) {
          onToggle();
          return; // Consume hit
        }
      }
      _tap.addPointer(event);
    }
  }

  void _handleTap() {
    onTap();
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }
}

extension on Size {
  Offset getOffset() => Offset(width, height);
}
