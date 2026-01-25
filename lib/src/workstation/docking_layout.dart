// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// An advanced docking primitive managed by a RenderObject.
/// Supports tiling children (tiles) and resizing them.
class DockingLayout extends MultiChildRenderObjectWidget {
  const DockingLayout({
    super.key,
    super.children,
    this.initialWeights,
    this.orientation = Axis.horizontal,
  });

  /// Initial flex weights for children if not specified via ParentData.
  final List<double>? initialWeights;
  final Axis orientation;

  @override
  RenderDockingLayout createRenderObject(BuildContext context) {
    return RenderDockingLayout(
      orientation: orientation,
      initialWeights: initialWeights,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDockingLayout renderObject,
  ) {
    renderObject
      ..orientation = orientation
      ..initialWeights = initialWeights;
  }
}

class DockingLayoutParentData extends ContainerBoxParentData<RenderBox> {
  double? flex; // Relative size
}

class RenderDockingLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DockingLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DockingLayoutParentData> {
  RenderDockingLayout({
    Axis orientation = Axis.horizontal,
    List<double>? initialWeights,
  }) : _orientation = orientation,
       _initialWeights = initialWeights;

  Axis _orientation;
  set orientation(Axis val) {
    if (_orientation != val) {
      _orientation = val;
      markNeedsLayout();
    }
  }

  List<double>? _initialWeights;
  set initialWeights(List<double>? val) {
    _initialWeights = val;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DockingLayoutParentData) {
      child.parentData = DockingLayoutParentData();
    }
  }

  @override
  void performLayout() {
    if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
      size = constraints.constrain(Size.zero);
      return;
    }
    size = constraints.biggest;

    double totalFlex = 0;
    int childCount = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as DockingLayoutParentData;
      if (pd.flex == null) {
        if (_initialWeights != null && childCount < _initialWeights!.length) {
          pd.flex = _initialWeights![childCount];
        } else {
          pd.flex = 1.0;
        }
      }
      totalFlex += pd.flex!;
      childCount++;
      child = childAfter(child);
    }

    if (childCount == 0) return;

    if (totalFlex == 0) {
      totalFlex = childCount.toDouble();
      child = firstChild;
      while (child != null) {
        (child.parentData as DockingLayoutParentData).flex = 1.0;
        child = childAfter(child);
      }
    }

    double offset = 0;
    child = firstChild;
    while (child != null) {
      final pd = child.parentData as DockingLayoutParentData;
      final flex = pd.flex ?? 1.0;
      final fraction = flex / totalFlex;

      BoxConstraints innerConstraints;
      if (_orientation == Axis.horizontal) {
        double w = size.width * fraction;
        innerConstraints = BoxConstraints.tightFor(
          width: w,
          height: size.height,
        );
        pd.offset = Offset(offset, 0);
        offset += w;
      } else {
        double h = size.height * fraction;
        innerConstraints = BoxConstraints.tightFor(
          width: size.width,
          height: h,
        );
        pd.offset = Offset(0, offset);
        offset += h;
      }

      child.layout(innerConstraints, parentUsesSize: true);
      child = childAfter(child);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
