import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A lowest-level sliver header following the "Direct Rendering" philosophy.
/// It paints its own title directly using RenderObject APIs instead of composing widgets.
class SliverHeader extends SingleChildRenderObjectWidget {
  const SliverHeader({
    super.key,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.title,
    super.child, // Optional background widget
    this.backgroundColor,
    this.pinned = true,
  });

  final double expandedHeight;
  final double collapsedHeight;
  final String title;
  final Color? backgroundColor;
  final bool pinned;

  @override
  RenderSliverHeader createRenderObject(BuildContext context) {
    return RenderSliverHeader(
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      title: title,
      backgroundColor: backgroundColor,
      pinned: pinned,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverHeader renderObject,
  ) {
    renderObject
      ..expandedHeight = expandedHeight
      ..collapsedHeight = collapsedHeight
      ..title = title
      ..backgroundColor = backgroundColor
      ..pinned = pinned;
  }
}

class RenderSliverHeader extends RenderSliverSingleBoxAdapter {
  RenderSliverHeader({
    required double expandedHeight,
    required double collapsedHeight,
    required String title,
    Color? backgroundColor,
    required bool pinned,
  }) : _expandedHeight = expandedHeight,
       _collapsedHeight = collapsedHeight,
       _titleText = title,
       _backgroundColor = backgroundColor,
       _pinned = pinned {
    _updatePainter();
  }

  double _expandedHeight;
  set expandedHeight(double value) {
    if (_expandedHeight == value) return;
    _expandedHeight = value;
    markNeedsLayout();
  }

  double _collapsedHeight;
  set collapsedHeight(double value) {
    if (_collapsedHeight == value) return;
    _collapsedHeight = value;
    markNeedsLayout();
  }

  String _titleText;
  set title(String value) {
    if (_titleText == value) return;
    _titleText = value;
    _updatePainter();
    markNeedsLayout();
  }

  Color? _backgroundColor;
  set backgroundColor(Color? value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  bool _pinned;
  set pinned(bool value) {
    if (_pinned == value) return;
    _pinned = value;
    markNeedsLayout();
  }

  late TextPainter _titlePainter;
  void _updatePainter() {
    _titlePainter = TextPainter(
      text: TextSpan(
        text: _titleText,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void performLayout() {
    final double maxExtent = _expandedHeight;
    final double minExtent = _collapsedHeight;
    final double scrollOffset = constraints.scrollOffset;

    double paintExtent = maxExtent - scrollOffset;
    if (_pinned) {
      paintExtent = paintExtent.clamp(minExtent, maxExtent);
    } else {
      paintExtent = paintExtent.clamp(0.0, maxExtent);
    }

    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintExtent: paintExtent,
      maxPaintExtent: maxExtent,
      layoutExtent: paintExtent,
      hitTestExtent: paintExtent,
    );

    if (child != null) {
      child!.layout(
        constraints.asBoxConstraints(
          minExtent: paintExtent,
          maxExtent: paintExtent,
        ),
        parentUsesSize: false,
      );
    }

    _titlePainter.layout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible) {
      final double paintExtent = geometry!.paintExtent;
      final Rect rect = offset & Size(constraints.crossAxisExtent, paintExtent);

      // 1. Direct Background Paint
      if (_backgroundColor != null) {
        context.canvas.drawRect(rect, Paint()..color = _backgroundColor!);
      }

      // 2. Child Background Paint
      if (child != null) {
        context.paintChild(child!, offset);
      }

      // 3. Direct Title Paint (with interpolation)
      final double maxExtent = _expandedHeight;
      final double minExtent = _collapsedHeight;
      final double t = (paintExtent - minExtent) / (maxExtent - minExtent);
      final double clampedT = t.clamp(0.0, 1.0);

      final double scale = 0.8 + (0.2 * clampedT);
      final double x = 16.0;
      final double y =
          paintExtent -
          (_titlePainter.height * scale) -
          (16.0 * clampedT) -
          (8.0 * (1.0 - clampedT));

      context.canvas.save();
      context.canvas.translate(offset.dx + x, offset.dy + y);
      context.canvas.scale(scale, scale);
      _titlePainter.paint(context.canvas, Offset.zero);
      context.canvas.restore();
    }
  }

  // RenderSliverSingleBoxAdapter implements hitTestChildren and applyPaintTransform by default.
}
