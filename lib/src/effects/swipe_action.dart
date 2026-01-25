import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A swipe-to-reveal actions widget using lowest-level APIs.
class SwipeAction extends SingleChildRenderObjectWidget {
  const SwipeAction({
    super.key,
    required Widget child,
    this.leftActions = const [],
    this.rightActions = const [],
    this.actionExtent = 80.0,
    this.threshold = 0.4,
  }) : super(child: child);

  final List<SwipeActionItem> leftActions;
  final List<SwipeActionItem> rightActions;
  final double actionExtent;
  final double threshold;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSwipeAction(
      leftActions: leftActions,
      rightActions: rightActions,
      actionExtent: actionExtent,
      threshold: threshold,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSwipeAction renderObject,
  ) {
    renderObject
      ..leftActions = leftActions
      ..rightActions = rightActions
      ..actionExtent = actionExtent
      ..threshold = threshold;
  }
}

class SwipeActionItem {
  const SwipeActionItem({
    required this.child,
    required this.onPressed,
    this.backgroundColor = const Color(0xFFFF0000),
  });

  final Widget child;
  final VoidCallback onPressed;
  final Color backgroundColor;
}

class RenderSwipeAction extends RenderProxyBox {
  RenderSwipeAction({
    required List<SwipeActionItem> leftActions,
    required List<SwipeActionItem> rightActions,
    required double actionExtent,
    required this.threshold,
  }) : _leftActions = leftActions,
       _rightActions = rightActions,
       _actionExtent = actionExtent {
    _drag = HorizontalDragGestureRecognizer()
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  late HorizontalDragGestureRecognizer _drag;
  double _dragOffset = 0.0;

  List<SwipeActionItem> _leftActions;
  List<SwipeActionItem> get leftActions => _leftActions;
  set leftActions(List<SwipeActionItem> value) {
    _leftActions = value;
    markNeedsPaint();
  }

  List<SwipeActionItem> _rightActions;
  List<SwipeActionItem> get rightActions => _rightActions;
  set rightActions(List<SwipeActionItem> value) {
    _rightActions = value;
    markNeedsPaint();
  }

  double _actionExtent;
  double get actionExtent => _actionExtent;
  set actionExtent(double value) {
    if (_actionExtent == value) return;
    _actionExtent = value;
    markNeedsPaint();
  }

  double threshold;

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

  void _handleDragUpdate(DragUpdateDetails details) {
    final maxLeft = _leftActions.length * _actionExtent;
    final maxRight = _rightActions.length * _actionExtent;
    _dragOffset = (_dragOffset + details.delta.dx).clamp(-maxRight, maxLeft);
    markNeedsPaint();
  }

  void _handleDragEnd(DragEndDetails details) {
    final leftTotal = _leftActions.length * _actionExtent;
    final rightTotal = _rightActions.length * _actionExtent;

    if (_dragOffset > leftTotal * threshold) {
      _dragOffset = leftTotal;
    } else if (_dragOffset < -rightTotal * threshold) {
      _dragOffset = -rightTotal;
    } else {
      _dragOffset = 0;
    }
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Draw left actions (revealed when swiping right)
    if (_leftActions.isNotEmpty && _dragOffset > 0) {
      double x = offset.dx;
      for (final action in _leftActions) {
        canvas.drawRect(
          Rect.fromLTWH(x, offset.dy, _actionExtent, size.height),
          Paint()..color = action.backgroundColor,
        );
        x += _actionExtent;
      }
    }

    // Draw right actions (revealed when swiping left)
    if (_rightActions.isNotEmpty && _dragOffset < 0) {
      double x = offset.dx + size.width - _actionExtent;
      for (final action in _rightActions.reversed) {
        canvas.drawRect(
          Rect.fromLTWH(x, offset.dy, _actionExtent, size.height),
          Paint()..color = action.backgroundColor,
        );
        x -= _actionExtent;
      }
    }

    // Paint child translated
    if (child != null) {
      context.paintChild(child!, offset + Offset(_dragOffset, 0));
    }
  }
}
