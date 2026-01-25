// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderOverflowBox - Boundary-breaking layout logic
// =============================================================================

class OverflowBoxPrimitive extends SingleChildRenderObjectWidget {
  const OverflowBoxPrimitive({
    super.key,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.alignment = Alignment.center,
    super.child,
  });
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;
  final Alignment alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderOverflowBoxPrimitive(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      alignment: alignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverflowBoxPrimitive renderObject,
  ) {
    renderObject
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..minHeight = minHeight
      ..maxHeight = maxHeight
      ..alignment = alignment;
  }
}

class RenderOverflowBoxPrimitive extends RenderShiftedBox {
  RenderOverflowBoxPrimitive({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
    Alignment alignment = Alignment.center,
    RenderBox? child,
  }) : _minWidth = minWidth,
       _maxWidth = maxWidth,
       _minHeight = minHeight,
       _maxHeight = maxHeight,
       _alignment = alignment,
       super(child);

  double? _minWidth;
  set minWidth(double? value) {
    if (_minWidth != value) {
      _minWidth = value;
      markNeedsLayout();
    }
  }

  double? _maxWidth;
  set maxWidth(double? value) {
    if (_maxWidth != value) {
      _maxWidth = value;
      markNeedsLayout();
    }
  }

  double? _minHeight;
  set minHeight(double? value) {
    if (_minHeight != value) {
      _minHeight = value;
      markNeedsLayout();
    }
  }

  double? _maxHeight;
  set maxHeight(double? value) {
    if (_maxHeight != value) {
      _maxHeight = value;
      markNeedsLayout();
    }
  }

  Alignment _alignment;
  set alignment(Alignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    if (child != null) {
      child!.layout(
        BoxConstraints(
          minWidth: _minWidth ?? 0,
          maxWidth: _maxWidth ?? double.infinity,
          minHeight: _minHeight ?? 0,
          maxHeight: _maxHeight ?? double.infinity,
        ),
        parentUsesSize: true,
      );
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = _alignment.alongOffset(
        size - child!.size as Offset,
      );
    }
  }
}
