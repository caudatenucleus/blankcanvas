// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'flex_parent_data_primitive.dart';

// =============================================================================
// RenderFlex - Flexible 1D linear layout engine
// =============================================================================

class FlexPrimitive extends MultiChildRenderObjectWidget {
  const FlexPrimitive({
    super.key,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    super.children = const [],
  });

  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlexPrimitive(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFlexPrimitive renderObject,
  ) {
    renderObject
      ..direction = direction
      ..mainAxisAlignment = mainAxisAlignment
      ..crossAxisAlignment = crossAxisAlignment
      ..mainAxisSize = mainAxisSize;
  }
}

class RenderFlexPrimitive extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentDataPrimitive>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentDataPrimitive> {
  RenderFlexPrimitive({
    Axis direction = Axis.horizontal,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    List<RenderBox>? children,
  }) : _direction = direction,
       _mainAxisAlignment = mainAxisAlignment,
       _crossAxisAlignment = crossAxisAlignment,
       _mainAxisSize = mainAxisSize {
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

  MainAxisAlignment _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment != value) {
      _mainAxisAlignment = value;
      markNeedsLayout();
    }
  }

  CrossAxisAlignment _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  MainAxisSize _mainAxisSize;
  set mainAxisSize(MainAxisSize value) {
    if (_mainAxisSize != value) {
      _mainAxisSize = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexParentDataPrimitive) {
      child.parentData = FlexParentDataPrimitive();
    }
  }

  double _getMainSize(Size s) =>
      _direction == Axis.horizontal ? s.width : s.height;
  double _getCrossSize(Size s) =>
      _direction == Axis.horizontal ? s.height : s.width;

  @override
  void performLayout() {
    final double maxMain = _direction == Axis.horizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    final double maxCross = _direction == Axis.horizontal
        ? constraints.maxHeight
        : constraints.maxWidth;

    int totalFlex = 0;
    double allocatedSize = 0;
    double crossSize = 0;

    // First pass: layout non-flex children
    RenderBox? child = firstChild;
    while (child != null) {
      final FlexParentDataPrimitive pd =
          child.parentData! as FlexParentDataPrimitive;
      if (pd.flex == 0) {
        final BoxConstraints inner = _direction == Axis.horizontal
            ? BoxConstraints(maxHeight: maxCross)
            : BoxConstraints(maxWidth: maxCross);
        child.layout(inner, parentUsesSize: true);
        allocatedSize += _getMainSize(child.size);
        if (_getCrossSize(child.size) > crossSize) {
          crossSize = _getCrossSize(child.size);
        }
      } else {
        totalFlex += pd.flex.toInt();
      }
      child = pd.nextSibling;
    }

    // Second pass: layout flex children
    final double freeSpace = (maxMain - allocatedSize).clamp(
      0.0,
      double.infinity,
    );
    final double spacePerFlex = totalFlex > 0 ? freeSpace / totalFlex : 0;

    child = firstChild;
    while (child != null) {
      final FlexParentDataPrimitive pd =
          child.parentData! as FlexParentDataPrimitive;
      if (pd.flex > 0) {
        final double childMain = spacePerFlex * pd.flex;
        final BoxConstraints inner = _direction == Axis.horizontal
            ? BoxConstraints.tightFor(
                width: childMain,
              ).enforce(BoxConstraints(maxHeight: maxCross))
            : BoxConstraints.tightFor(
                height: childMain,
              ).enforce(BoxConstraints(maxWidth: maxCross));
        child.layout(inner, parentUsesSize: true);
        allocatedSize += _getMainSize(child.size);
        if (_getCrossSize(child.size) > crossSize) {
          crossSize = _getCrossSize(child.size);
        }
      }
      child = pd.nextSibling;
    }

    // Position children
    double mainOffset = 0;
    child = firstChild;
    while (child != null) {
      final FlexParentDataPrimitive pd =
          child.parentData! as FlexParentDataPrimitive;
      final double crossPos = _crossAxisAlignment == CrossAxisAlignment.start
          ? 0
          : _crossAxisAlignment == CrossAxisAlignment.end
          ? crossSize - _getCrossSize(child.size)
          : (crossSize - _getCrossSize(child.size)) / 2;

      pd.offset = _direction == Axis.horizontal
          ? Offset(mainOffset, crossPos)
          : Offset(crossPos, mainOffset);
      mainOffset += _getMainSize(child.size);
      child = pd.nextSibling;
    }

    final double idealMain = _mainAxisSize == MainAxisSize.max
        ? maxMain
        : allocatedSize;
    size = _direction == Axis.horizontal
        ? constraints.constrain(Size(idealMain, crossSize))
        : constraints.constrain(Size(crossSize, idealMain));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
