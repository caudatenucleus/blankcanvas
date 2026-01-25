// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderStackPositioned - Absolute-offset child logic
// =============================================================================

class StackPositionedPrimitive extends SingleChildRenderObjectWidget {
  const StackPositionedPrimitive({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    super.child,
  });

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderStackPositionedPrimitive(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStackPositionedPrimitive renderObject,
  ) {
    renderObject
      ..positionedLeft = left
      ..positionedTop = top
      ..positionedRight = right
      ..positionedBottom = bottom
      ..positionedWidth = width
      ..positionedHeight = height;
  }
}

class RenderStackPositionedPrimitive extends RenderProxyBox {
  RenderStackPositionedPrimitive({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
    RenderBox? child,
  }) : _left = left,
       _top = top,
       _right = right,
       _bottom = bottom,
       _width = width,
       _height = height,
       super(child);

  double? _left;
  double? get positionedLeft => _left;
  set positionedLeft(double? value) {
    if (_left != value) {
      _left = value;
      markNeedsLayout();
    }
  }

  double? _top;
  double? get positionedTop => _top;
  set positionedTop(double? value) {
    if (_top != value) {
      _top = value;
      markNeedsLayout();
    }
  }

  double? _right;
  double? get positionedRight => _right;
  set positionedRight(double? value) {
    if (_right != value) {
      _right = value;
      markNeedsLayout();
    }
  }

  double? _bottom;
  double? get positionedBottom => _bottom;
  set positionedBottom(double? value) {
    if (_bottom != value) {
      _bottom = value;
      markNeedsLayout();
    }
  }

  double? _width;
  double? get positionedWidth => _width;
  set positionedWidth(double? value) {
    if (_width != value) {
      _width = value;
      markNeedsLayout();
    }
  }

  double? _height;
  double? get positionedHeight => _height;
  set positionedHeight(double? value) {
    if (_height != value) {
      _height = value;
      markNeedsLayout();
    }
  }

  // Note: Actual positioning is done by Stack parent, this just holds the data.
  // For a true implementation, this would need to be part of Stack's layout protocol.
}
