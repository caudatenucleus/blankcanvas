import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A widget that detects navigation gestures like edge swipes.
class GestureNavigation extends SingleChildRenderObjectWidget {
  const GestureNavigation({
    super.key,
    required Widget child,
    this.onBack,
    this.onHome,
    this.edgeWidth = 20.0,
    this.tag,
  }) : super(child: child);

  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final double edgeWidth;
  final String? tag;

  @override
  RenderGestureNavigation createRenderObject(BuildContext context) {
    return RenderGestureNavigation(onBack: onBack, edgeWidth: edgeWidth);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderGestureNavigation renderObject,
  ) {
    renderObject
      ..onBack = onBack
      ..edgeWidth = edgeWidth;
  }
}

class RenderGestureNavigation extends RenderProxyBox {
  RenderGestureNavigation({VoidCallback? onBack, double edgeWidth = 20.0})
    : _onBack = onBack,
      _edgeWidth = edgeWidth {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  VoidCallback? _onBack;
  set onBack(VoidCallback? value) => _onBack = value;

  // VoidCallback? _onHome;
  // set onHome(VoidCallback? value) => _onHome = value;

  double _edgeWidth;
  set edgeWidth(double value) => _edgeWidth = value;

  late HorizontalDragGestureRecognizer _drag;
  bool _isBackGesture = false;

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }

  void _handleDragStart(DragStartDetails details) {
    if (details.localPosition.dx <= _edgeWidth) {
      _isBackGesture = true;
    } else {
      _isBackGesture = false;
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // maybe visualize drag
  }

  void _handleDragEnd(DragEndDetails details) {
    const double kMinVelocity = 100.0; // logical pixels/sec
    // Allow if velocity is high enough OR if the intent was clearly a back swipe?
    // Usually standard back gesture relies on position updates too (iOS style).
    // Here we just check if it was a valid start.

    if (_isBackGesture) {
      if (details.primaryVelocity! > kMinVelocity) {
        _onBack?.call();
      }
    }
  }

  @override
  bool hitTestSelf(Offset position) {
    // We only care if tap is on edge, allowing basic hits to pass through?
    // Actually, GestureRecognizer adds itself to arena.
    // We need to participate in hit test.

    // If we return true, we consume hits?
    // RenderProxyBox hitTestChildren calls child.hitTest.
    // If child handles it, we are fine.
    // But we want to detect gestures ON TOP of child?
    // Yes.
    return true;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }
}
