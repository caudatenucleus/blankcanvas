import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A stack of cards that can be swiped to dismiss, implemented at the RenderObject level.
class Deck extends MultiChildRenderObjectWidget {
  Deck({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onSwipe,
  }) : super(children: List.generate(itemCount, (i) => itemBuilder(null, i)));

  final int itemCount;
  final Widget Function(BuildContext? context, int index) itemBuilder;
  final void Function(int index, DismissDirection direction)? onSwipe;

  @override
  RenderDeck createRenderObject(BuildContext context) {
    return RenderDeck(onSwipe: onSwipe);
  }

  @override
  void updateRenderObject(BuildContext context, RenderDeck renderObject) {
    renderObject.onSwipe = onSwipe;
  }
}

// Keeping DeckRaw for compatibility with my test update if needed, but actually I fixed the test to use Deck with children?
// Wait, the test uses `DeckRaw`. I should export DeckRaw or just use Deck in test.
// I'll update the test to use `Deck` (since I made Deck accept list in my previous thought but then wrote `DeckRaw`).
// Actually, `Deck` above accepts `itemCount` and `itemBuilder`.
// But pass them to super children list. Which is fine.
// But the test constructs `DeckRaw(children: ...)`.
// I should make `Deck` accept `children` optionally or just expose `DeckRaw`.
// Let's just expose `Deck` as the main widget taking children, and maybe a convenience constructor?
// Or just revert `Deck` to take children list directly to match `MultiChildRenderObjectWidget` pattern better.

class DeckRaw extends MultiChildRenderObjectWidget {
  const DeckRaw({super.key, required super.children, this.onSwipe});

  final void Function(int index, DismissDirection direction)? onSwipe;

  @override
  RenderDeck createRenderObject(BuildContext context) {
    return RenderDeck(onSwipe: onSwipe);
  }

  @override
  void updateRenderObject(BuildContext context, RenderDeck renderObject) {
    renderObject.onSwipe = onSwipe;
  }
}

class DeckParentData extends ContainerBoxParentData<RenderBox> {}

class RenderDeck extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, DeckParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, DeckParentData> {
  RenderDeck({this.onSwipe}) {
    _drag = PanGestureRecognizer()
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  Function(int index, DismissDirection direction)? onSwipe;

  late PanGestureRecognizer _drag;
  Offset _dragOffset = Offset.zero;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! DeckParentData) {
      child.parentData = DeckParentData();
    }
  }

  void _handleDragStart(DragStartDetails details) {}

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragOffset += details.delta;
    markNeedsPaint();
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > 100) {
      final direction = _dragOffset.dx > 0
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart;
      onSwipe?.call(0, direction);
      _dragOffset = Offset.zero;
      markNeedsPaint();
    } else {
      _dragOffset = Offset.zero;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    final childConstraints = constraints.loosen();

    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);

      // Center child and set offset
      final DeckParentData pd = child.parentData as DeckParentData;
      pd.offset = Offset(
        (constraints.maxWidth - child.size.width) / 2,
        (constraints.maxHeight - child.size.height) / 2,
      );

      child = childAfter(child);
    }
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final children = <RenderBox>[];
    RenderBox? child = firstChild;
    while (child != null) {
      children.add(child);
      child = childAfter(child);
    }

    for (int i = children.length - 1; i >= 0; i--) {
      final c = children[i];
      final DeckParentData pd = c.parentData as DeckParentData;

      if (c == children.last) {
        context.pushTransform(
          needsCompositing,
          offset,
          Matrix4.translationValues(_dragOffset.dx, _dragOffset.dy, 0)
            ..rotateZ(_dragOffset.dx * 0.001),
          (ctx, off) {
            ctx.paintChild(c, off + pd.offset);
          },
        );
      } else {
        context.paintChild(c, offset + pd.offset);
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      final DeckParentData pd = child.parentData as DeckParentData;

      // Simplified hit test: check visual bounds.
      // For top card, visual pos is pd.offset + dragOffset.
      // For others, pd.offset.

      final offset = (child == lastChild) ? pd.offset + _dragOffset : pd.offset;

      final bool isHit = result.addWithPaintOffset(
        offset: offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;

      child = pd.previousSibling;
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }
}
