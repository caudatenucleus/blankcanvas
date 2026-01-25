// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderFractionallySizedBox - Percentage-based layout logic
// =============================================================================

class FractionallySizedBoxPrimitive extends SingleChildRenderObjectWidget {
  const FractionallySizedBoxPrimitive({
    super.key,
    this.widthFactor,
    this.heightFactor,
    this.alignment = Alignment.center,
    super.child,
  });
  final double? widthFactor;
  final double? heightFactor;
  final Alignment alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFractionallySizedBoxPrimitive(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      alignment: alignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFractionallySizedBoxPrimitive renderObject,
  ) {
    renderObject
      ..widthFactor = widthFactor
      ..heightFactor = heightFactor
      ..alignment = alignment;
  }
}

class RenderFractionallySizedBoxPrimitive extends RenderShiftedBox {
  RenderFractionallySizedBoxPrimitive({
    double? widthFactor,
    double? heightFactor,
    Alignment alignment = Alignment.center,
    RenderBox? child,
  }) : _widthFactor = widthFactor,
       _heightFactor = heightFactor,
       _alignment = alignment,
       super(child);

  double? _widthFactor;
  double? get widthFactor => _widthFactor;
  set widthFactor(double? value) {
    if (_widthFactor != value) {
      _widthFactor = value;
      markNeedsLayout();
    }
  }

  double? _heightFactor;
  double? get heightFactor => _heightFactor;
  set heightFactor(double? value) {
    if (_heightFactor != value) {
      _heightFactor = value;
      markNeedsLayout();
    }
  }

  Alignment _alignment;
  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    final double? wFactor = _widthFactor;
    final double? hFactor = _heightFactor;

    BoxConstraints childConstraints = constraints;
    if (wFactor != null) {
      childConstraints = childConstraints.copyWith(
        minWidth: constraints.maxWidth * wFactor,
        maxWidth: constraints.maxWidth * wFactor,
      );
    }
    if (hFactor != null) {
      childConstraints = childConstraints.copyWith(
        minHeight: constraints.maxHeight * hFactor,
        maxHeight: constraints.maxHeight * hFactor,
      );
    }

    if (child != null) {
      child!.layout(childConstraints, parentUsesSize: true);
      size = constraints.constrain(child!.size);
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = _alignment.alongOffset(
        size - child!.size as Offset,
      );
    } else {
      size = constraints.constrain(
        Size(
          wFactor != null ? constraints.maxWidth * wFactor : 0,
          hFactor != null ? constraints.maxHeight * hFactor : 0,
        ),
      );
    }
  }
}
