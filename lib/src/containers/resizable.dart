import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A container that can be resized by dragging its edges.
class Resizable extends SingleChildRenderObjectWidget {
  const Resizable({
    super.key,
    required Widget child,
    this.initialWidth = 200,
    this.initialHeight = 200,
    this.minWidth = 50,
    this.minHeight = 50,
    this.onResize,
    this.tag,
  }) : super(child: child);

  final double initialWidth;
  final double initialHeight;
  final double minWidth;
  final double minHeight;
  final ValueChanged<Size>? onResize;
  final String? tag;

  @override
  RenderResizable createRenderObject(BuildContext context) {
    return RenderResizable(
      initialWidth: initialWidth,
      initialHeight: initialHeight,
      minWidth: minWidth,
      minHeight: minHeight,
      onResize: onResize,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderResizable renderObject) {
    renderObject
      ..minWidth = minWidth
      ..minHeight = minHeight
      ..onResize = onResize;
  }
}

class RenderResizable extends RenderProxyBox {
  RenderResizable({
    required double initialWidth,
    required double initialHeight,
    required double minWidth,
    required double minHeight,
    ValueChanged<Size>? onResize,
  }) : _currentWidth = initialWidth,
       _currentHeight = initialHeight,
       _minWidth = minWidth,
       _minHeight = minHeight,
       _onResize = onResize {
    _horizDrag = HorizontalDragGestureRecognizer()..onUpdate = _handleHorizDrag;
    _vertDrag = VerticalDragGestureRecognizer()..onUpdate = _handleVertDrag;
    _panDrag = PanGestureRecognizer()..onUpdate = _handlePanDrag;
  }

  double _currentWidth;
  double _currentHeight;

  double _minWidth;
  set minWidth(double value) => _minWidth = value;

  double _minHeight;
  set minHeight(double value) => _minHeight = value;

  ValueChanged<Size>? _onResize;
  set onResize(ValueChanged<Size>? value) => _onResize = value;

  late HorizontalDragGestureRecognizer _horizDrag;
  late VerticalDragGestureRecognizer _vertDrag;
  late PanGestureRecognizer _panDrag;

  static const double _handleSize = 10.0;
  static const double _cornerSize = 15.0;

  Rect _rightHandle = Rect.zero;
  Rect _bottomHandle = Rect.zero;
  Rect _cornerHandle = Rect.zero;

  @override
  void detach() {
    _horizDrag.dispose();
    _vertDrag.dispose();
    _panDrag.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    child?.layout(
      BoxConstraints.tight(Size(_currentWidth, _currentHeight)),
      parentUsesSize: true,
    );
    size = constraints.constrain(Size(_currentWidth, _currentHeight));

    _rightHandle = Rect.fromLTWH(
      size.width - _handleSize,
      0,
      _handleSize,
      size.height - _cornerSize,
    );
    _bottomHandle = Rect.fromLTWH(
      0,
      size.height - _handleSize,
      size.width - _cornerSize,
      _handleSize,
    );
    _cornerHandle = Rect.fromLTWH(
      size.width - _cornerSize,
      size.height - _cornerSize,
      _cornerSize,
      _cornerSize,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    // Draw corner indicator
    final cornerRect = _cornerHandle.shift(offset);
    context.canvas.drawRect(
      cornerRect,
      Paint()..color = const Color(0x22000000),
    );
  }

  void _handleHorizDrag(DragUpdateDetails details) {
    _currentWidth = math.max(_minWidth, _currentWidth + details.delta.dx);
    _onResize?.call(Size(_currentWidth, _currentHeight));
    markNeedsLayout();
  }

  void _handleVertDrag(DragUpdateDetails details) {
    _currentHeight = math.max(_minHeight, _currentHeight + details.delta.dy);
    _onResize?.call(Size(_currentWidth, _currentHeight));
    markNeedsLayout();
  }

  void _handlePanDrag(DragUpdateDetails details) {
    _currentWidth = math.max(_minWidth, _currentWidth + details.delta.dx);
    _currentHeight = math.max(_minHeight, _currentHeight + details.delta.dy);
    _onResize?.call(Size(_currentWidth, _currentHeight));
    markNeedsLayout();
  }

  @override
  bool hitTestSelf(Offset position) {
    return _rightHandle.contains(position) ||
        _bottomHandle.contains(position) ||
        _cornerHandle.contains(position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      final pos = event.localPosition;
      if (_cornerHandle.contains(pos)) {
        _panDrag.addPointer(event);
      } else if (_rightHandle.contains(pos)) {
        _horizDrag.addPointer(event);
      } else if (_bottomHandle.contains(pos)) {
        _vertDrag.addPointer(event);
      }
    }
  }
}
