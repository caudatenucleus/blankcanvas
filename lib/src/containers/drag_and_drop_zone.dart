import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that defines a zone for accepting dropped items using lowest-level APIs.
/// Uses a custom Element to handle the builder rebuilding on state changes.
class DragAndDropZone<T extends Object> extends RenderObjectWidget {
  const DragAndDropZone({
    super.key,
    required this.builder,
    this.onDrop,
    this.onWillAccept,
    this.onLeave,
    this.tag,
  });

  final Widget Function(BuildContext context, bool candidate, dynamic rejected)
  builder;
  final ValueChanged<T>? onDrop;
  final bool Function(T? data)? onWillAccept;
  final VoidCallback? onLeave;
  final String? tag;

  @override
  DragAndDropZoneElement<T> createElement() => DragAndDropZoneElement<T>(this);

  @override
  RenderDragTarget<T> createRenderObject(BuildContext context) {
    return RenderDragTarget<T>(
      onDrop: onDrop,
      onWillAccept: onWillAccept,
      onLeave: onLeave,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDragTarget<T> renderObject,
  ) {
    renderObject
      ..onDrop = onDrop
      ..onWillAccept = onWillAccept
      ..onLeave = onLeave;
  }
}

class DragAndDropZoneElement<T extends Object> extends RenderObjectElement {
  DragAndDropZoneElement(DragAndDropZone<T> super.widget);

  Element? _child;

  // State
  bool _candidate = false;
  dynamic _rejected = false; // Simplified

  @override
  RenderDragTarget<T> get renderObject =>
      super.renderObject as RenderDragTarget<T>;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    renderObject.element = this;
    _build();
  }

  void updateState(bool candidate, dynamic rejected) {
    if (_candidate != candidate || _rejected != rejected) {
      _candidate = candidate;
      _rejected = rejected;
      markNeedsBuild();
    }
  }

  @override
  void performRebuild() {
    super.performRebuild();
    _build();
  }

  void _build() {
    final DragAndDropZone<T> widget = this.widget as DragAndDropZone<T>;
    final Widget built = widget.builder(this, _candidate, _rejected);
    _child = updateChild(_child, built, null);
  }

  @override
  void update(DragAndDropZone<T> newWidget) {
    super.update(newWidget);
    // Builder might change, rebuild
    _build();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) visitor(_child!);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    final RenderDragTarget<T> renderObject = this.renderObject;
    renderObject.child = child as RenderBox?;
  }

  @override
  void moveRenderObjectChild(
    RenderObject child,
    Object? oldSlot,
    Object? newSlot,
  ) {
    // Single child, no move
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final RenderDragTarget<T> renderObject = this.renderObject;
    renderObject.child = null;
  }
}

class RenderDragTarget<T extends Object> extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderDragTarget({this.onDrop, this.onWillAccept, this.onLeave});

  ValueChanged<T>? onDrop;
  bool Function(T? data)? onWillAccept;
  VoidCallback? onLeave;

  DragAndDropZoneElement<T>? element;

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints, parentUsesSize: true);
      size = child!.size;
    } else {
      size = constraints.biggest;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Always hit test self if we want to be a target?
    // Actually standard hitTest calls hitTestSelf after children.
    // We want to capture hits on us.
    if (child != null && child!.hitTest(result, position: position)) {
      return true;
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  // Interaction API called by Draggable
  void handleDragEnter(dynamic data) {
    // Check type?
    if (data is T) {
      bool accept = onWillAccept?.call(data) ?? true;
      element?.updateState(accept, !accept);
    } else {
      // Reject
      element?.updateState(false, true);
    }
  }

  void handleDragLeave() {
    onLeave?.call();
    element?.updateState(false, false);
  }

  void handleDrop(dynamic data) {
    if (data is T) {
      if (onWillAccept?.call(data) ?? true) {
        onDrop?.call(data);
      }
    }
    element?.updateState(false, false);
  }
}

/// A draggable item wrapper.
class DraggableItem<T extends Object> extends SingleChildRenderObjectWidget {
  const DraggableItem({
    super.key,
    required this.data,
    required Widget child,
    required this.feedback,
    this.childWhenDragging,
    this.tag,
  }) : super(child: child);

  final T data;
  final Widget feedback;
  final Widget? childWhenDragging;
  final String? tag;

  @override
  RenderDraggable<T> createRenderObject(BuildContext context) {
    return RenderDraggable<T>(
      data: data,
      feedback: feedback,
      overlay: Overlay.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderDraggable<T> renderObject,
  ) {
    renderObject
      ..data = data
      ..feedback = feedback;
  }
}

class RenderDraggable<T extends Object> extends RenderProxyBox {
  RenderDraggable({
    required T data,
    required Widget feedback,
    required OverlayState overlay,
  }) : _data = data,
       _feedback = feedback,
       _overlay = overlay {
    _drag = PanGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  T _data;
  set data(T value) {
    _data = value;
  }

  Widget _feedback;
  set feedback(Widget value) {
    _feedback = value;
  }

  final OverlayState _overlay;

  late PanGestureRecognizer _drag;
  OverlayEntry? _entry;
  RenderDragTarget<T>? _activeTarget;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  void _handleDragStart(DragStartDetails details) {
    // Create overlay
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: details.globalPosition.dx,
          top: details.globalPosition.dy,
          child: IgnorePointer(child: _feedback),
        );
      },
    );
    _overlay.insert(_entry!);

    // Optionally fade child?
    markNeedsPaint();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // Update overlay position
    _entry?.markNeedsBuild(); // Rebuild with new pos?
    // Wait, OverlayEntry builder is called once? NO, if we setState in overlay?
    // Can't easily setState inside OverlayEntry builder without stateful shell.
    // Hack: remove and reinsert? Slow.
    // Better: Helper widget in overlay that listens to position stream.
    // For now: remove and insert.
    _entry?.remove();
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: details.globalPosition.dx,
          top: details.globalPosition.dy,
          child: IgnorePointer(child: _feedback),
        );
      },
    );
    _overlay.insert(_entry!);

    // Hit test for targets
    final HitTestResult result = HitTestResult();
    // ignore: deprecated_member_use
    RendererBinding.instance.hitTest(result, details.globalPosition);

    RenderDragTarget<T>? newTarget;
    for (final HitTestEntry entry in result.path) {
      if (entry.target is RenderDragTarget<T>) {
        newTarget = entry.target as RenderDragTarget<T>;
        break;
      }
    }

    if (newTarget != _activeTarget) {
      _activeTarget?.handleDragLeave();
      _activeTarget = newTarget;
      _activeTarget?.handleDragEnter(_data);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _entry?.remove();
    _entry = null;

    _activeTarget?.handleDrop(_data);
    _activeTarget = null;
    markNeedsPaint();
  }

  void _handleDragCancel() {
    _entry?.remove();
    _entry = null;
    _activeTarget?.handleDragLeave();
    _activeTarget = null;
    markNeedsPaint();
  }
}
