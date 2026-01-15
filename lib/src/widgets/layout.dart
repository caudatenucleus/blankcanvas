import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A low-level layout primitive that combines padding, alignment, and constraints.
class LayoutBox extends SingleChildRenderObjectWidget {
  const LayoutBox({
    super.key,
    super.child,
    this.padding = EdgeInsets.zero,
    this.alignment,
    this.width,
    this.height,
  });

  final EdgeInsetsGeometry padding;
  final AlignmentGeometry? alignment;
  final double? width;
  final double? height;

  @override
  RenderLayoutBox createRenderObject(BuildContext context) {
    return RenderLayoutBox(
      padding: padding,
      alignment: alignment,
      width: width,
      height: height,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderLayoutBox renderObject,
  ) {
    renderObject
      ..padding = padding
      ..alignment = alignment
      ..width = width
      ..height = height;
  }
}

class RenderLayoutBox extends RenderProxyBox {
  RenderLayoutBox({
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    AlignmentGeometry? alignment,
    double? width,
    double? height,
  }) : _padding = padding,
       _alignment = alignment,
       _width = width,
       _height = height;

  EdgeInsetsGeometry _padding;
  EdgeInsetsGeometry get padding => _padding;
  set padding(EdgeInsetsGeometry value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  AlignmentGeometry? _alignment;
  AlignmentGeometry? get alignment => _alignment;
  set alignment(AlignmentGeometry? value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  double? _width;
  double? get width => _width;
  set width(double? value) {
    if (_width == value) return;
    _width = value;
    markNeedsLayout();
  }

  double? _height;
  double? get height => _height;
  set height(double? value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final EdgeInsets resolvedPadding = padding.resolve(TextDirection.ltr);

    if (child != null) {
      BoxConstraints childConstraints = constraints.deflate(resolvedPadding);

      if (width != null) {
        childConstraints = childConstraints.tighten(
          width: width! - resolvedPadding.horizontal,
        );
      }
      if (height != null) {
        childConstraints = childConstraints.tighten(
          height: height! - resolvedPadding.vertical,
        );
      }

      child!.layout(childConstraints.loosen(), parentUsesSize: true);

      final Size childSize = child!.size;
      final double totalWidth =
          (width ?? childSize.width + resolvedPadding.horizontal).clamp(
            constraints.minWidth,
            constraints.maxWidth,
          );
      final double totalHeight =
          (height ?? childSize.height + resolvedPadding.vertical).clamp(
            constraints.minHeight,
            constraints.maxHeight,
          );

      size = Size(totalWidth, totalHeight);

      // Handle alignment
      if (alignment != null) {
        final Alignment resolvedAlignment = alignment!.resolve(
          TextDirection.ltr,
        );
        final BoxParentData childParentData =
            child!.parentData! as BoxParentData;

        final double freeWidth =
            size.width - childSize.width - resolvedPadding.horizontal;
        final double freeHeight =
            size.height - childSize.height - resolvedPadding.vertical;

        childParentData.offset =
            resolvedPadding.topLeft +
            resolvedAlignment.alongOffset(Offset(freeWidth, freeHeight));
      } else {
        final BoxParentData childParentData =
            child!.parentData! as BoxParentData;
        childParentData.offset = resolvedPadding.topLeft;
      }
    } else {
      size = constraints.constrain(Size(width ?? 0.0, height ?? 0.0));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      context.paintChild(child!, childParentData.offset + offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - childParentData.offset);
        return child!.hitTest(result, position: transformed);
      },
    );
  }
}

/// A low-level flex-based layout primitive (unified Row/Column).
class FlexBox extends MultiChildRenderObjectWidget {
  const FlexBox({
    super.key,
    super.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 0.0,
  });

  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  @override
  RenderFlexBox createRenderObject(BuildContext context) {
    return RenderFlexBox(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderFlexBox renderObject,
  ) {
    renderObject
      ..direction = direction
      ..mainAxisAlignment = mainAxisAlignment
      ..crossAxisAlignment = crossAxisAlignment
      ..spacing = spacing;
  }
}

class FlexParentData extends ContainerBoxParentData<RenderBox> {}

class RenderFlexBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData> {
  RenderFlexBox({
    Axis direction = Axis.horizontal,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    double spacing = 0.0,
  }) : _direction = direction,
       _mainAxisAlignment = mainAxisAlignment,
       _crossAxisAlignment = crossAxisAlignment,
       _spacing = spacing;

  Axis _direction;
  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  MainAxisAlignment _mainAxisAlignment;
  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment == value) return;
    _mainAxisAlignment = value;
    markNeedsLayout();
  }

  CrossAxisAlignment _crossAxisAlignment;
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment == value) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  double _spacing;
  double get spacing => _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexParentData) {
      child.parentData = FlexParentData();
    }
  }

  @override
  void performLayout() {
    double mainSize = 0.0;
    double crossSize = 0.0;
    int childCount = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      final Size childSize = child.size;

      if (direction == Axis.horizontal) {
        mainSize += childSize.width;
        if (childCount > 0) mainSize += spacing;
        crossSize = crossSize > childSize.height ? crossSize : childSize.height;
      } else {
        mainSize += childSize.height;
        if (childCount > 0) mainSize += spacing;
        crossSize = crossSize > childSize.width ? crossSize : childSize.width;
      }

      childCount++;
      child = childAfter(child);
    }

    size = constraints.constrain(
      direction == Axis.horizontal
          ? Size(mainSize, crossSize)
          : Size(crossSize, mainSize),
    );

    // Positioning
    double currentMain = 0.0;

    // Main Axis Alignment (very basic)
    if (mainAxisAlignment == MainAxisAlignment.end) {
      currentMain =
          (direction == Axis.horizontal ? size.width : size.height) - mainSize;
    } else if (mainAxisAlignment == MainAxisAlignment.center) {
      currentMain =
          ((direction == Axis.horizontal ? size.width : size.height) -
              mainSize) /
          2;
    }

    child = firstChild;
    while (child != null) {
      final FlexParentData childParentData =
          child.parentData! as FlexParentData;
      final Size childSize = child.size;

      double currentCross = 0.0;
      if (crossAxisAlignment == CrossAxisAlignment.center) {
        currentCross =
            ((direction == Axis.horizontal ? size.height : size.width) -
                (direction == Axis.horizontal
                    ? childSize.height
                    : childSize.width)) /
            2;
      } else if (crossAxisAlignment == CrossAxisAlignment.end) {
        currentCross =
            (direction == Axis.horizontal ? size.height : size.width) -
            (direction == Axis.horizontal ? childSize.height : childSize.width);
      }

      if (direction == Axis.horizontal) {
        childParentData.offset = Offset(currentMain, currentCross);
        currentMain += childSize.width + spacing;
      } else {
        childParentData.offset = Offset(currentCross, currentMain);
        currentMain += childSize.height + spacing;
      }

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
