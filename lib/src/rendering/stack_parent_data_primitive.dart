// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderStack - Overlapping 2D layout engine
// =============================================================================

class _StackParentDataPrimitive extends ContainerBoxParentData<RenderBox> {
  double? top;
  double? right;
  double? bottom;
  double? left;
  double? width;
  double? height;

  bool get isPositioned =>
      top != null ||
      right != null ||
      bottom != null ||
      left != null ||
      width != null ||
      height != null;
}

class StackPrimitive extends MultiChildRenderObjectWidget {
  const StackPrimitive({
    super.key,
    this.alignment = Alignment.topLeft,
    this.fit = StackFit.loose,
    super.children = const [],
  });

  final Alignment alignment;
  final StackFit fit;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderStackPrimitive(alignment: alignment, fit: fit);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStackPrimitive renderObject,
  ) {
    renderObject
      ..alignment = alignment
      ..fit = fit;
  }
}

class RenderStackPrimitive extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _StackParentDataPrimitive>,
        RenderBoxContainerDefaultsMixin<RenderBox, _StackParentDataPrimitive> {
  RenderStackPrimitive({
    Alignment alignment = Alignment.topLeft,
    StackFit fit = StackFit.loose,
    List<RenderBox>? children,
  }) : _alignment = alignment,
       _fit = fit {
    addAll(children);
  }

  Alignment _alignment;
  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  StackFit _fit;
  StackFit get fit => _fit;
  set fit(StackFit value) {
    if (_fit != value) {
      _fit = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _StackParentDataPrimitive) {
      child.parentData = _StackParentDataPrimitive();
    }
  }

  @override
  void performLayout() {
    double width = 0;
    double height = 0;

    BoxConstraints nonPositionedConstraints = _fit == StackFit.loose
        ? constraints.loosen()
        : _fit == StackFit.expand
        ? BoxConstraints.tight(constraints.biggest)
        : constraints;

    // First pass: layout non-positioned children to get size
    RenderBox? child = firstChild;
    while (child != null) {
      final _StackParentDataPrimitive pd =
          child.parentData! as _StackParentDataPrimitive;
      if (!pd.isPositioned) {
        child.layout(nonPositionedConstraints, parentUsesSize: true);
        if (child.size.width > width) width = child.size.width;
        if (child.size.height > height) height = child.size.height;
      }
      child = pd.nextSibling;
    }

    size = constraints.constrain(Size(width, height));

    // Second pass: layout and position all children
    child = firstChild;
    while (child != null) {
      final _StackParentDataPrimitive pd =
          child.parentData! as _StackParentDataPrimitive;
      if (pd.isPositioned) {
        double childWidth =
            pd.width ?? (size.width - (pd.left ?? 0) - (pd.right ?? 0));
        double childHeight =
            pd.height ?? (size.height - (pd.top ?? 0) - (pd.bottom ?? 0));
        child.layout(
          BoxConstraints.tightFor(
            width: childWidth.clamp(0, double.infinity),
            height: childHeight.clamp(0, double.infinity),
          ),
          parentUsesSize: true,
        );

        double x =
            pd.left ??
            (pd.right != null ? size.width - pd.right! - child.size.width : 0);
        double y =
            pd.top ??
            (pd.bottom != null
                ? size.height - pd.bottom! - child.size.height
                : 0);
        pd.offset = Offset(x, y);
      } else {
        pd.offset = _alignment.alongOffset(size - child.size as Offset);
      }
      child = pd.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
