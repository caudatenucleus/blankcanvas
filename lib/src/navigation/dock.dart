import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A dock widget using lowest-level APIs.
class Dock extends MultiChildRenderObjectWidget {
  const Dock({
    super.key,
    required super.children, // renamed from items to children for consistency
    this.height = 64,
    this.backgroundColor = const Color(0xCCFFFFFF),
    this.borderRadius = 16,
    this.itemSpacing = 16,
  });

  // Helper constructor to maintain API compatibility if named 'items' was used
  const Dock.items({
    Key? key,
    required List<Widget> items,
    double height = 64,
    Color backgroundColor = const Color(0xCCFFFFFF),
    double borderRadius = 16,
    double itemSpacing = 16,
  }) : this(
         key: key,
         children: items,
         height: height,
         backgroundColor: backgroundColor,
         borderRadius: borderRadius,
         itemSpacing: itemSpacing,
       );

  final double height;
  final Color backgroundColor;
  final double borderRadius;
  final double itemSpacing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDock(
      height: height,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      itemSpacing: itemSpacing,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDock renderObject) {
    renderObject
      ..height = height
      ..backgroundColor = backgroundColor
      ..borderRadius = borderRadius
      ..itemSpacing = itemSpacing;
  }
}

class DockParentData extends ContainerBoxParentData<RenderBox> {}

class RenderDock extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DockParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DockParentData> {
  RenderDock({
    required double height,
    required Color backgroundColor,
    required double borderRadius,
    required double itemSpacing,
  }) : _height = height,
       _backgroundColor = backgroundColor,
       _borderRadius = borderRadius,
       _itemSpacing = itemSpacing;

  double _height;
  double get height => _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  double _borderRadius;
  double get borderRadius => _borderRadius;
  set borderRadius(double value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  double _itemSpacing;
  double get itemSpacing => _itemSpacing;
  set itemSpacing(double value) {
    if (_itemSpacing == value) return;
    _itemSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DockParentData) {
      child.parentData = DockParentData();
    }
  }

  @override
  void performLayout() {
    double totalWidth = 0.0;
    int childCount = 0;

    // Layout children to measure them
    RenderBox? child = firstChild;
    while (child != null) {
      final DockParentData childParentData =
          child.parentData! as DockParentData;

      // Constrain height, allow unlimited width for now (flex logic requires more)
      child.layout(
        BoxConstraints(maxHeight: _height - 32), // 16 padding top/bottom
        parentUsesSize: true,
      );

      totalWidth += child.size.width;
      childCount++;

      child = childParentData.nextSibling;
    }

    // Add spacing and padding
    totalWidth += (childCount > 0 ? (childCount - 1) * _itemSpacing : 0);
    totalWidth += 32; // 16 padding left/right

    // Constrain own size
    size = constraints.constrain(Size(totalWidth, _height));

    // Position children
    double x = 16;
    double yCenter = _height / 2;

    child = firstChild;
    while (child != null) {
      final DockParentData childParentData =
          child.parentData! as DockParentData;

      childParentData.offset = Offset(x, yCenter - (child.size.height / 2));

      x += child.size.width + _itemSpacing;
      child = childParentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x20000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      Radius.circular(_borderRadius),
    );

    // Draw shadow slightly offset
    canvas.drawRRect(rrect.shift(const Offset(0, 10)), shadowPaint);

    // Background
    final paint = Paint()..color = _backgroundColor;
    canvas.drawRRect(rrect, paint);

    defaultPaint(context, offset);
  }
}
