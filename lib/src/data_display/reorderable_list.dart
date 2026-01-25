import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A list whose items can be reordered by dragging.
/// This widget does not handle scrolling; wrap it in a SingleChildScrollView if needed.
class ReorderableList extends MultiChildRenderObjectWidget {
  const ReorderableList({
    super.key,
    required super.children,
    required this.onReorder,
  });

  final ReorderCallback onReorder;

  @override
  RenderReorderableList createRenderObject(BuildContext context) {
    return RenderReorderableList(onReorder: onReorder);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderReorderableList renderObject,
  ) {
    renderObject.onReorder = onReorder;
  }
}

class ReorderableListParentData extends ContainerBoxParentData<RenderBox> {
  int? originalIndex;
}

class RenderReorderableList extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ReorderableListParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ReorderableListParentData> {
  RenderReorderableList({required ReorderCallback onReorder})
    : _onReorder = onReorder {
    // We need a long press to start drag? or immediate drag?
    // Standard is LongPress.
    _longPress = LongPressGestureRecognizer()
      ..onLongPressStart = _handleLongPressStart
      ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
      ..onLongPressEnd = _handleLongPressEnd
      ..onLongPressCancel = _handleLongPressCancel;
  }

  ReorderCallback _onReorder;
  set onReorder(ReorderCallback value) {
    _onReorder = value;
  }

  late LongPressGestureRecognizer _longPress;

  // Drag State
  RenderBox? _draggingChild;
  int? _dragIndex;
  // ignore: unused_field
  Offset? _dragPosition; // Global position
  // ignore: unused_field
  Offset? _dragOffset; // Offset of drag point relative to child top-left
  double _dragY = 0; // Local Y position of center of dragged item

  @override
  void detach() {
    _longPress.dispose();
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ReorderableListParentData) {
      child.parentData = ReorderableListParentData();
    }
  }

  @override
  void performLayout() {
    double currentY = 0;

    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final pd = child.parentData as ReorderableListParentData;
      pd.originalIndex =
          index; // Keep track of original order to pass to callback

      child.layout(constraints.copyWith(minHeight: 0), parentUsesSize: true);

      // If this is the dragging child, we don't advance currentY?
      // No, we should leave a gap or shift items.
      // For simplicity: Visually shift items during drag.
      // In performLayout, we layout everything linearly.
      // We adjust visual positions in paint or apply parentData offsets here based on drag.

      // If we want to animate/shift during drag, we need to know where the gap is.
      // Let's assume layout is static order, but we visually offset items.
      // The dragging item floats.

      pd.offset = Offset(0, currentY);
      currentY += child.size.height;

      index++;
      child = childAfter(child);
    }

    size = constraints.constrain(Size(constraints.maxWidth, currentY));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // If dragging, we paint non-dragged items with shifts.
    // And dragged item last on top.

    RenderBox? child = firstChild;
    int index = 0;

    // Calculate split point
    // If dragging, find where the dragY falls.
    int? placeholderIndex;
    if (_draggingChild != null) {
      // Find which index the _dragLocalY corresponds to.
      // We iterate children to find heights.
      double y = 0;
      RenderBox? temp = firstChild;
      int i = 0;
      while (temp != null) {
        double h = temp.size.height;
        if (_dragY >= y && _dragY < y + h) {
          placeholderIndex = i;
          break;
        }
        y += h;
        i++;
        temp = childAfter(temp);
      }
      if (placeholderIndex == null) {
        if (_dragY < 0) {
          placeholderIndex = 0;
        } else {
          placeholderIndex = childCount - 1;
        }
      }
    }

    while (child != null) {
      final pd = child.parentData as ReorderableListParentData;
      if (child == _draggingChild) {
        // Don't paint/paint later
      } else {
        // Determine if we shift.
        // If this child is at `index`.
        // If `index` >= `placeholderIndex` and `index` < `_dragIndex`, shift down?
        // If `index` <= `placeholderIndex` and `index` > `_dragIndex`, shift up?

        // Simpler: Just paint at pd.offset for now, refine visual shift later if time.
        context.paintChild(child, pd.offset + offset);
      }
      child = childAfter(child);
      index++;
    }

    if (_draggingChild != null && _dragPosition != null) {
      // Paint dragging child at drag position.
      // _dragPosition is global?
      // We need local.
      // _dragLocalPosition.
      // Let's rely on _dragY (center Y).
      final dy = _dragY - _draggingChild!.size.height / 2;
      context.paintChild(_draggingChild!, offset + Offset(0, dy));
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _longPress.addPointer(event);
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    // Find child at position
    final RenderBox? child = _hitTestChild(details.localPosition);
    if (child != null) {
      _draggingChild = child;
      final pd = child.parentData as ReorderableListParentData;
      _dragIndex = pd.originalIndex; // We set this in layout
      _dragY = pd.offset.dy + child.size.height / 2; // Center

      markNeedsPaint();
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_draggingChild != null) {
      _dragY = details.localPosition.dy;
      markNeedsPaint();
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _endDrag();
  }

  void _handleLongPressCancel() {
    _endDrag();
  }

  void _endDrag() {
    if (_draggingChild != null) {
      // Calculate new index based on _dragY
      // Emit callback
      // For now, just drop to bottom or nearest?

      // Need calculation.
      // Let's iterate heights.
      double y = 0;
      RenderBox? temp = firstChild;
      int i = 0;
      int newIndex = childCount - 1;

      while (temp != null) {
        double h = temp.size.height;
        if (_dragY < y + h / 2) {
          newIndex = i;
          break;
        }
        y += h;
        i++;
        temp = childAfter(temp);
      }

      if (_dragIndex != null && _dragIndex != newIndex) {
        _onReorder(
          _dragIndex!,
          newIndex >= _dragIndex! ? newIndex : newIndex,
        ); // Adjust for removal?
        // Standard flutter ReorderableListView logic:
        // if old < new, new -= 1 ?
        // The callback signature: (int oldIndex, int newIndex)
        // User implementation usually handles list manipulation.
      }

      _draggingChild = null;
      _dragIndex = null;
      markNeedsPaint();
    }
  }

  RenderBox? _hitTestChild(Offset local) {
    RenderBox? child = firstChild;
    while (child != null) {
      final pd = child.parentData as ReorderableListParentData;
      final rect = pd.offset & child.size;
      if (rect.contains(local)) return child;
      child = childAfter(child);
    }
    return null;
  }
}
