import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'canvas_status.dart';

/// The Soul: Handles interaction.
class CanvasControl extends SingleChildRenderObjectWidget {
  const CanvasControl({
    super.key,
    required Widget child,
    this.onPressed,
    this.onHover,
    this.onFocus,
    this.isDisabled = false,
    this.cursor = SystemMouseCursors.click,
    this.statusListener,
  }) : super(child: child);

  final VoidCallback? onPressed;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocus;
  final bool isDisabled;
  final MouseCursor cursor;
  final ValueChanged<ControlStatus>? statusListener;

  @override
  RenderCanvasControl createRenderObject(BuildContext context) {
    return RenderCanvasControl(
      onPressed: onPressed,
      onHover: onHover,
      onFocus: onFocus,
      isDisabled: isDisabled,
      cursor: cursor,
      statusListener: statusListener,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCanvasControl renderObject,
  ) {
    renderObject
      ..onPressed = onPressed
      ..onHover = onHover
      ..onFocus = onFocus
      ..isDisabled = isDisabled
      ..cursor = cursor
      ..statusListener = statusListener;
  }
}

class RenderCanvasControl extends RenderProxyBox
    implements MouseTrackerAnnotation {
  RenderCanvasControl({
    VoidCallback? onPressed,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocus,
    bool isDisabled = false,
    MouseCursor cursor = SystemMouseCursors.click,
    ValueChanged<ControlStatus>? statusListener,
  }) : _onPressed = onPressed,
       _onHover = onHover,
       _onFocus = onFocus,
       _isDisabled = isDisabled,
       _cursor = cursor,
       _statusListener = statusListener;

  VoidCallback? _onPressed;
  set onPressed(VoidCallback? value) => _onPressed = value;

  ValueChanged<bool>? _onHover;
  set onHover(ValueChanged<bool>? value) => _onHover = value;

  ValueChanged<bool>? _onFocus;
  set onFocus(ValueChanged<bool>? value) => _onFocus = value;

  bool _isDisabled;
  set isDisabled(bool value) {
    if (_isDisabled != value) {
      _isDisabled = value;
      _updateStatus();
    }
  }

  MouseCursor _cursor;
  set cursor(MouseCursor value) {
    if (_cursor != value) {
      _cursor = value;
      // Mouse tracker update handled by re-hit testing usually, implies paint too?
      markNeedsPaint();
    }
  }

  ValueChanged<ControlStatus>? _statusListener;
  set statusListener(ValueChanged<ControlStatus>? value) =>
      _statusListener = value;

  ControlStatus _status = const ControlStatus();
  bool _isHovered = false;
  bool _isPressed = false;
  final bool _isFocused = false;

  void _updateStatus() {
    final newStatus = ControlStatus(
      isHovered: _isHovered,
      isPressed: _isPressed,
      isFocused: _isFocused,
      isDisabled: _isDisabled,
    );

    if (_status != newStatus) {
      _status = newStatus;
      if (_statusListener != null) {
        _statusListener!(newStatus);
      }
      if (_onFocus != null) {
        _onFocus!(_isFocused);
      }
      markNeedsPaint();
    }
  }

  // Propagate status to children if they are CanvasBoxes?
  // We can implement a standardized interface for children that accept status.
  // Or utilize the visitor pattern.
  // For now, simple paint invalidation.

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (_isDisabled) return;

    if (event is PointerDownEvent) {
      _isPressed = true;
      _updateStatus();
    } else if (event is PointerUpEvent) {
      if (_isPressed) {
        _isPressed = false;
        _updateStatus();
        if (_onPressed != null) _onPressed!();
      }
    } else if (event is PointerCancelEvent) {
      _isPressed = false;
      _updateStatus();
    }
    // Hover handled by MouseTrackerAnnotation
  }

  // MouseTrackerAnnotation implementation
  void _handleMouseEnter(PointerEnterEvent event) {
    if (_isDisabled) return;
    _isHovered = true;
    _updateStatus();
    if (_onHover != null) _onHover!(true);
  }

  void _handleMouseExit(PointerExitEvent event) {
    if (_isDisabled) return;
    _isHovered = false;
    _updateStatus();
    if (_onHover != null) _onHover!(false);
  }

  @override
  MouseCursor get cursor =>
      _isDisabled ? SystemMouseCursors.forbidden : _cursor;

  @override
  PointerEnterEventListener? get onEnter => _handleMouseEnter;

  @override
  PointerExitEventListener? get onExit => _handleMouseExit;

  @override
  bool get validForMouseTracker => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    // We can paint debug status?
    // Pass status to child if possible?
    // "CanvasDecoration... receives ControlStatus from parent CanvasControl".
    // This implies the decoration is stored here OR child pulls it.
    // The instructions say: CanvasControl wraps CanvasBox.
    // So CanvasBox is the child.
    // In paint(), we can check if child is RenderCanvasBox and update its status.
    if (child is StatusAwareRenderObject) {
      (child as StatusAwareRenderObject).controlStatus = _status;
    }
    super.paint(context, offset);
  }
}
