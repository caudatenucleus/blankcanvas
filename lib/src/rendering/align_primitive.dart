// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderAlign - Alignment positioning engine
// =============================================================================

class AlignPrimitive extends SingleChildRenderObjectWidget {
  const AlignPrimitive({
    super.key,
    this.alignment = Alignment.center,
    this.widthFactor,
    this.heightFactor,
    super.child,
  });
  final Alignment alignment;
  final double? widthFactor;
  final double? heightFactor;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAlignPrimitive(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAlignPrimitive renderObject,
  ) {
    renderObject
      ..alignment = alignment
      ..widthFactor = widthFactor
      ..heightFactor = heightFactor;
  }
}

class RenderAlignPrimitive extends RenderShiftedBox {
  RenderAlignPrimitive({
    Alignment alignment = Alignment.center,
    double? widthFactor,
    double? heightFactor,
    RenderBox? child,
  }) : _alignment = alignment,
       _widthFactor = widthFactor,
       _heightFactor = heightFactor,
       super(child);

  Alignment _alignment;
  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  double? _widthFactor;
  set widthFactor(double? value) {
    if (_widthFactor != value) {
      _widthFactor = value;
      markNeedsLayout();
    }
  }

  double? _heightFactor;
  set heightFactor(double? value) {
    if (_heightFactor != value) {
      _heightFactor = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    final bool shrinkWrapWidth =
        _widthFactor != null || constraints.maxWidth == double.infinity;
    final bool shrinkWrapHeight =
        _heightFactor != null || constraints.maxHeight == double.infinity;

    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      size = constraints.constrain(
        Size(
          shrinkWrapWidth
              ? child!.size.width * (_widthFactor ?? 1.0)
              : double.infinity,
          shrinkWrapHeight
              ? child!.size.height * (_heightFactor ?? 1.0)
              : double.infinity,
        ),
      );
      final BoxParentData pd = child!.parentData! as BoxParentData;
      pd.offset = _alignment.alongOffset(size - child!.size as Offset);
    } else {
      size = constraints.constrain(
        Size(
          shrinkWrapWidth ? 0.0 : double.infinity,
          shrinkWrapHeight ? 0.0 : double.infinity,
        ),
      );
    }
  }
}
