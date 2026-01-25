import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A simplified masonry layout using lowest-level APIs.
/// Note: Changed API from `itemBuilder` to `children` list to adhere to RenderObject strictness
/// without complex element management. Callers should map children upfront.
class Masonry extends MultiChildRenderObjectWidget {
  const Masonry({
    super.key,
    super.children,
    this.columnCount = 2,
    this.spacing = 8,
  });

  final int columnCount;
  final double spacing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMasonry(columnCount: columnCount, spacing: spacing);
  }

  @override
  void updateRenderObject(BuildContext context, RenderMasonry renderObject) {
    renderObject
      ..columnCount = columnCount
      ..spacing = spacing;
  }
}

class MasonryParentData extends ContainerBoxParentData<RenderBox> {}

class RenderMasonry extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MasonryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MasonryParentData> {
  RenderMasonry({required int columnCount, required double spacing})
    : _columnCount = columnCount,
      _spacing = spacing;

  int _columnCount;
  int get columnCount => _columnCount;
  set columnCount(int value) {
    if (_columnCount == value) return;
    _columnCount = value;
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
    if (child.parentData is! MasonryParentData) {
      child.parentData = MasonryParentData();
    }
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }

    final double width = constraints.maxWidth;
    // Default to at least 1 column to avoid divide by zero if user passes 0
    final int cols = _columnCount > 0 ? _columnCount : 1;
    final double itemWidth = (width - (cols - 1) * _spacing) / cols;

    // Track height of each column
    final List<double> colHeights = List.filled(cols, 0.0);

    RenderBox? child = firstChild;
    while (child != null) {
      final MasonryParentData childParentData =
          child.parentData! as MasonryParentData;

      // Layout child with fixed width
      child.layout(
        BoxConstraints(minWidth: itemWidth, maxWidth: itemWidth),
        parentUsesSize: true,
      );

      // Find shortest column
      int colIndex = 0;
      double minHeight = colHeights[0];
      for (int i = 1; i < cols; i++) {
        if (colHeights[i] < minHeight) {
          minHeight = colHeights[i];
          colIndex = i;
        }
      }

      // Position child
      final double x = colIndex * (itemWidth + _spacing);
      final double y = minHeight > 0 ? minHeight + _spacing : 0;
      childParentData.offset = Offset(x, y);

      // Update column height
      colHeights[colIndex] = y + child.size.height;

      child = childParentData.nextSibling;
    }

    // Size is max width and max column height
    double maxHeight = 0;
    for (double h in colHeights) {
      if (h > maxHeight) maxHeight = h;
    }

    size = constraints.constrain(Size(width, maxHeight));
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
