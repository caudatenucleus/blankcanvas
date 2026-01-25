// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'box_model_edge_primitive.dart';
import 'box_model_constraints_primitive.dart';

// =============================================================================
// RenderBoxModelLayout - The final composited layout node
// =============================================================================

class BoxModelLayoutPrimitive extends SingleChildRenderObjectWidget {
  const BoxModelLayoutPrimitive({
    super.key,
    this.edges = const BoxModelEdgePrimitive(),
    this.constraints,
    this.decoration,
    super.child,
  });

  final BoxModelEdgePrimitive edges;
  final BoxModelConstraintsPrimitive? constraints;
  final BoxDecoration? decoration;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBoxModelLayoutPrimitive(
      edges: edges,
      modelConstraints: constraints,
      decoration: decoration,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBoxModelLayoutPrimitive renderObject,
  ) {
    renderObject
      ..edges = edges
      ..modelConstraints = constraints
      ..decoration = decoration;
  }
}

class RenderBoxModelLayoutPrimitive extends RenderProxyBox {
  RenderBoxModelLayoutPrimitive({
    BoxModelEdgePrimitive edges = const BoxModelEdgePrimitive(),
    BoxModelConstraintsPrimitive? modelConstraints,
    BoxDecoration? decoration,
    RenderBox? child,
  }) : _edges = edges,
       _modelConstraints = modelConstraints,
       _decoration = decoration,
       super(child);

  BoxModelEdgePrimitive _edges;
  BoxModelEdgePrimitive get edges => _edges;
  set edges(BoxModelEdgePrimitive value) {
    if (_edges != value) {
      _edges = value;
      markNeedsLayout();
    }
  }

  BoxModelConstraintsPrimitive? _modelConstraints;
  BoxModelConstraintsPrimitive? get modelConstraints => _modelConstraints;
  set modelConstraints(BoxModelConstraintsPrimitive? value) {
    if (_modelConstraints != value) {
      _modelConstraints = value;
      markNeedsLayout();
    }
  }

  BoxDecoration? _decoration;
  BoxDecoration? get decoration => _decoration;
  set decoration(BoxDecoration? value) {
    if (_decoration != value) {
      _decoration = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    final totalInsets = _edges.totalInsets;

    if (child != null) {
      // Deflate constraints by edge insets
      final childConstraints = constraints.deflate(totalInsets);

      // Apply model constraints if specified
      final effectiveConstraints = _modelConstraints != null
          ? childConstraints.enforce(_modelConstraints!.toBoxConstraints())
          : childConstraints;

      child!.layout(effectiveConstraints, parentUsesSize: true);

      // Size = child size + edge insets
      size = constraints.constrain(
        Size(
          child!.size.width + totalInsets.horizontal,
          child!.size.height + totalInsets.vertical,
        ),
      );
    } else {
      size = constraints.constrain(
        Size(totalInsets.horizontal, totalInsets.vertical),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint decoration (background, border, etc.)
    if (_decoration != null) {
      final painter = BoxDecoration(
        color: _decoration!.color,
        border: _decoration!.border,
        borderRadius: _decoration!.borderRadius,
        boxShadow: _decoration!.boxShadow,
      ).createBoxPainter();
      painter.paint(
        context.canvas,
        offset + Offset(_edges.margin.left, _edges.margin.top),
        ImageConfiguration(
          size: Size(
            size.width - _edges.margin.horizontal,
            size.height - _edges.margin.vertical,
          ),
        ),
      );
    }

    // Paint child at content offset
    if (child != null) {
      context.paintChild(child!, offset + _edges.contentOffset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      return result.addWithPaintOffset(
        offset: _edges.contentOffset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
    }
    return false;
  }
}
