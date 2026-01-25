// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// =============================================================================
// RenderWrap - Multi-line breaking layout engine
// =============================================================================

class _WrapParentDataPrimitive extends ContainerBoxParentData<RenderBox> {}

class WrapPrimitive extends MultiChildRenderObjectWidget {
  const WrapPrimitive({
    super.key,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    super.children = const [],
  });

  final Axis direction;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWrapPrimitive(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWrapPrimitive renderObject,
  ) {
    renderObject
      ..direction = direction
      ..alignment = alignment
      ..spacing = spacing
      ..runSpacing = runSpacing;
  }
}

class RenderWrapPrimitive extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _WrapParentDataPrimitive>,
        RenderBoxContainerDefaultsMixin<RenderBox, _WrapParentDataPrimitive> {
  RenderWrapPrimitive({
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    double runSpacing = 0.0,
    List<RenderBox>? children,
  }) : _direction = direction,
       _alignment = alignment,
       _spacing = spacing,
       _runSpacing = runSpacing {
    addAll(children);
  }

  Axis _direction;
  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  WrapAlignment _alignment;
  set alignment(WrapAlignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  double _spacing;
  set spacing(double value) {
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  double _runSpacing;
  set runSpacing(double value) {
    if (_runSpacing != value) {
      _runSpacing = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _WrapParentDataPrimitive) {
      child.parentData = _WrapParentDataPrimitive();
    }
  }

  @override
  void performLayout() {
    final double maxMainExtent = _direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;

    // Layout children into runs
    List<List<RenderBox>> runs = [];
    List<RenderBox> currentRun = [];
    double currentRunMainExtent = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(
        BoxConstraints.loose(constraints.biggest),
        parentUsesSize: true,
      );
      final double childMain = _direction == Axis.horizontal
          ? child.size.width
          : child.size.height;

      if (currentRun.isNotEmpty &&
          currentRunMainExtent + _spacing + childMain > maxMainExtent) {
        runs.add(currentRun);
        currentRun = [];
        currentRunMainExtent = 0;
      }
      currentRun.add(child);
      currentRunMainExtent +=
          (currentRun.length > 1 ? _spacing : 0) + childMain;

      final _WrapParentDataPrimitive pd =
          child.parentData! as _WrapParentDataPrimitive;
      child = pd.nextSibling;
    }
    if (currentRun.isNotEmpty) runs.add(currentRun);

    // Position children
    double crossOffset = 0;
    double maxCrossExtent = 0;
    for (final run in runs) {
      double mainOffset = 0;
      double runCrossExtent = 0;
      for (final child in run) {
        final double childCross = _direction == Axis.horizontal
            ? child.size.height
            : child.size.width;
        if (childCross > runCrossExtent) runCrossExtent = childCross;
      }
      for (final child in run) {
        final _WrapParentDataPrimitive pd =
            child.parentData! as _WrapParentDataPrimitive;
        if (_direction == Axis.horizontal) {
          pd.offset = Offset(mainOffset, crossOffset);
          mainOffset += child.size.width + _spacing;
        } else {
          pd.offset = Offset(crossOffset, mainOffset);
          mainOffset += child.size.height + _spacing;
        }
      }
      crossOffset += runCrossExtent + _runSpacing;
      if (crossOffset > maxCrossExtent) maxCrossExtent = crossOffset;
    }

    size = _direction == Axis.horizontal
        ? constraints.constrain(
            Size(maxMainExtent, maxCrossExtent - _runSpacing),
          )
        : constraints.constrain(
            Size(maxCrossExtent - _runSpacing, maxMainExtent),
          );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
