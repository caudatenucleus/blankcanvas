// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;
import 'virtual_list_layout_parent_data.dart';


class RenderVirtualList extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, VirtualListLayoutParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          VirtualListLayoutParentData
        > {
  RenderVirtualList({
    required Axis scrollDirection,
    required EdgeInsets padding,
    double? itemExtent,
    ScrollController? controller,
  }) : _scrollDirection = scrollDirection,
       _padding = padding,
       _itemExtent = itemExtent,
       _controller = controller {
    _drag = PanGestureRecognizer()..onUpdate = _handleDragUpdate;
  }

  Axis _scrollDirection;
  set scrollDirection(Axis val) {
    if (_scrollDirection != val) {
      _scrollDirection = val;
      markNeedsLayout();
    }
  }

  EdgeInsets _padding;
  set padding(EdgeInsets val) {
    if (_padding != val) {
      _padding = val;
      markNeedsLayout();
    }
  }

  double? _itemExtent;
  set itemExtent(double? val) {
    if (_itemExtent != val) {
      _itemExtent = val;
      markNeedsLayout();
    }
  }

  ScrollController? _controller;
  set controller(ScrollController? val) {
    if (_controller != val) {
      _controller = val;
      if (_controller != null && _controller!.hasClients) {
        _scrollOffset = _controller!.offset;
      }
    }
  }

  late PanGestureRecognizer _drag;
  double _scrollOffset = 0;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! VirtualListLayoutParentData) {
      child.parentData = VirtualListLayoutParentData();
    }
  }

  @override
  void performLayout() {
    double currentPos = _scrollDirection == Axis.vertical
        ? _padding.top
        : _padding.left;

    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as VirtualListLayoutParentData;

      if (_scrollDirection == Axis.vertical) {
        // Width is fixed to constraints
        // Height is itemExtent or intrinsic
        double w = math.max(0, constraints.maxWidth - _padding.horizontal);
        double h = _itemExtent ?? 0;
        BoxConstraints innerConstraints;

        if (_itemExtent != null) {
          innerConstraints = BoxConstraints.tightFor(width: w, height: h);
        } else {
          innerConstraints = BoxConstraints(minWidth: w, maxWidth: w);
        }

        child.layout(innerConstraints, parentUsesSize: true);
        pd.offset = Offset(_padding.left, currentPos);
        currentPos += child.size.height;
      } else {
        // Horizontal
        double h = math.max(0, constraints.maxHeight - _padding.vertical);
        double w = _itemExtent ?? 0;
        BoxConstraints innerConstraints;

        if (_itemExtent != null) {
          innerConstraints = BoxConstraints.tightFor(width: w, height: h);
        } else {
          innerConstraints = BoxConstraints(minHeight: h, maxHeight: h);
        }

        child.layout(innerConstraints, parentUsesSize: true);
        pd.offset = Offset(currentPos, _padding.top);
        currentPos += child.size.width;
      }

      child = childAfter(child);
    }

    if (_scrollDirection == Axis.vertical) {
      currentPos += _padding.bottom;
      size = constraints.biggest;
    } else {
      currentPos += _padding.right;
      size = constraints.biggest;
    }

    // Check scroll bounds
    _maxScrollExtent = math.max(
      0,
      currentPos -
          (_scrollDirection == Axis.vertical ? size.height : size.width),
    );
    _scrollOffset = _scrollOffset.clamp(0.0, _maxScrollExtent);
  }

  double _maxScrollExtent = 0;

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, (
      ctx,
      off,
    ) {
      RenderBox? child = firstChild;
      while (child != null) {
        final pd = child.parentData as VirtualListLayoutParentData;

        Offset childOffset;
        if (_scrollDirection == Axis.vertical) {
          childOffset = pd.offset - Offset(0, _scrollOffset);
          if (childOffset.dy + child.size.height > 0 &&
              childOffset.dy < size.height) {
            ctx.paintChild(child, off + childOffset);
          }
        } else {
          childOffset = pd.offset - Offset(_scrollOffset, 0);
          if (childOffset.dx + child.size.width > 0 &&
              childOffset.dx < size.width) {
            ctx.paintChild(child, off + childOffset);
          }
        }

        child = childAfter(child);
      }
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    double delta = _scrollDirection == Axis.vertical
        ? details.delta.dy
        : details.delta.dx;
    _scrollOffset -= delta;
    _scrollOffset = _scrollOffset.clamp(0.0, _maxScrollExtent);
    markNeedsPaint();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    Offset effectivePos = position;
    if (_scrollDirection == Axis.vertical) {
      effectivePos += Offset(0, _scrollOffset);
    } else {
      effectivePos += Offset(_scrollOffset, 0);
    }
    return defaultHitTestChildren(result, position: effectivePos);
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
