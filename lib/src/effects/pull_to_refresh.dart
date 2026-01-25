import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A pull-to-refresh widget using lowest-level APIs.
class PullToRefresh extends SingleChildRenderObjectWidget {
  const PullToRefresh({
    super.key,
    required Widget child,
    required this.onRefresh,
    this.displacement = 60.0,
    this.indicatorBuilder,
  }) : super(child: child);

  final Future<void> Function() onRefresh;
  final double displacement;
  final Widget Function(
    BuildContext context,
    double progress,
    bool isRefreshing,
  )?
  indicatorBuilder;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPullToRefresh(
      displacement: displacement,
      onRefresh: onRefresh,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPullToRefresh renderObject,
  ) {
    renderObject
      ..displacement = displacement
      ..onRefresh = onRefresh;
  }

  @override
  SingleChildRenderObjectElement createElement() => _PullToRefreshElement(this);
}

class _PullToRefreshElement extends SingleChildRenderObjectElement {
  _PullToRefreshElement(PullToRefresh super.widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (renderObject as RenderPullToRefresh)._element = this;
  }
}

class RenderPullToRefresh extends RenderProxyBox {
  RenderPullToRefresh({required double displacement, required this.onRefresh})
    : _displacement = displacement {
    _drag = VerticalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  late VerticalDragGestureRecognizer _drag;
  // ignore: unused_field
  _PullToRefreshElement? _element;

  double _displacement;
  double get displacement => _displacement;
  set displacement(double value) {
    if (_displacement == value) return;
    _displacement = value;
    markNeedsPaint();
  }

  Future<void> Function() onRefresh;

  double _dragOffset = 0.0;
  bool _isRefreshing = false;

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    // Nothing special needed
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isRefreshing) return;
    _dragOffset = (_dragOffset + details.delta.dy).clamp(
      0.0,
      _displacement * 2,
    );
    markNeedsPaint();
    markNeedsLayout();
  }

  void _handleDragEnd(DragEndDetails details) async {
    if (_isRefreshing) return;

    if (_dragOffset >= _displacement) {
      _isRefreshing = true;
      markNeedsPaint();

      await onRefresh();

      _isRefreshing = false;
      _dragOffset = 0.0;
      markNeedsPaint();
      markNeedsLayout();
    } else {
      _dragOffset = 0.0;
      markNeedsPaint();
      markNeedsLayout();
    }
  }

  void _handleDragCancel() {
    _dragOffset = 0.0;
    markNeedsPaint();
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child!.layout(constraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Draw indicator area
    if (_dragOffset > 0 || _isRefreshing) {
      final indicatorHeight = _dragOffset.clamp(0.0, _displacement);
      final progress = indicatorHeight / _displacement;

      // Draw background
      final indicatorRect = Rect.fromLTWH(
        offset.dx,
        offset.dy,
        size.width,
        indicatorHeight,
      );
      canvas.drawRect(indicatorRect, Paint()..color = const Color(0xFFEEEEEE));

      // Draw progress indicator
      final centerX = offset.dx + size.width / 2;
      final centerY = offset.dy + indicatorHeight / 2;

      if (_isRefreshing) {
        // Draw spinning indicator
        canvas.drawCircle(
          Offset(centerX, centerY),
          12,
          Paint()
            ..color = const Color(0xFF666666)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      } else {
        // Draw arrow
        final arrowPaint = Paint()
          ..color = const Color(0xFF666666)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(centerX, centerY - 8 * progress),
          Offset(centerX, centerY + 8 * progress),
          arrowPaint,
        );
        canvas.drawLine(
          Offset(centerX - 6 * progress, centerY + 2 * progress),
          Offset(centerX, centerY + 8 * progress),
          arrowPaint,
        );
        canvas.drawLine(
          Offset(centerX + 6 * progress, centerY + 2 * progress),
          Offset(centerX, centerY + 8 * progress),
          arrowPaint,
        );
      }
    }

    // Paint child translated down
    if (child != null) {
      context.paintChild(child!, offset + Offset(0, _dragOffset));
    }
  }
}
