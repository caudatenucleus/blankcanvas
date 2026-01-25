import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix4;

/// A stacked card layout with swipe-to-dismiss using lowest-level APIs.
class CardStack extends MultiChildRenderObjectWidget {
  CardStack({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onSwipe,
    this.stackOffset = const Offset(0, 10),
    this.scaleFactor = 0.95,
    this.visibleCards = 3,
  }) : super(
         children: List.generate(
           itemCount.clamp(0, visibleCards),
           (i) => itemBuilder(null, i),
         ),
       );

  final int itemCount;
  final Widget Function(BuildContext? context, int index) itemBuilder;
  final void Function(int index, DismissDirection direction)? onSwipe;
  final Offset stackOffset;
  final double scaleFactor;
  final int visibleCards;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCardStack(
      stackOffset: stackOffset,
      scaleFactor: scaleFactor,
      visibleCards: visibleCards,
      onSwipe: onSwipe,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCardStack renderObject) {
    renderObject
      ..stackOffset = stackOffset
      ..scaleFactor = scaleFactor
      ..visibleCards = visibleCards
      ..onSwipe = onSwipe;
  }
}

class CardStackParentData extends ContainerBoxParentData<RenderBox> {
  int index = 0;
}

class RenderCardStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CardStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CardStackParentData> {
  RenderCardStack({
    required Offset stackOffset,
    required double scaleFactor,
    required int visibleCards,
    this.onSwipe,
  }) : _stackOffset = stackOffset,
       _scaleFactor = scaleFactor,
       _visibleCards = visibleCards {
    _drag = PanGestureRecognizer()
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd;
  }

  Offset _stackOffset;
  Offset get stackOffset => _stackOffset;
  set stackOffset(Offset value) {
    if (_stackOffset == value) return;
    _stackOffset = value;
    markNeedsPaint();
  }

  double _scaleFactor;
  double get scaleFactor => _scaleFactor;
  set scaleFactor(double value) {
    if (_scaleFactor == value) return;
    _scaleFactor = value;
    markNeedsPaint();
  }

  int _visibleCards;
  int get visibleCards => _visibleCards;
  set visibleCards(int value) {
    if (_visibleCards == value) return;
    _visibleCards = value;
    markNeedsLayout();
  }

  void Function(int index, DismissDirection direction)? onSwipe;

  late PanGestureRecognizer _drag;
  Offset _dragOffset = Offset.zero;

  @override
  void detach() {
    _drag.dispose();
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! CardStackParentData) {
      child.parentData = CardStackParentData();
    }
  }

  @override
  void performLayout() {
    Size maxSize = Size.zero;
    int index = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final CardStackParentData childParentData =
          child.parentData! as CardStackParentData;
      childParentData.index = index;

      child.layout(constraints, parentUsesSize: true);
      if (child.size.width > maxSize.width) {
        maxSize = Size(child.size.width, maxSize.height);
      }
      if (child.size.height > maxSize.height) {
        maxSize = Size(maxSize.width, child.size.height);
      }

      child = childParentData.nextSibling;
      index++;
    }

    size = constraints.constrain(maxSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint from back to front
    // Children list: [Top, Next, Next...] (based on generation 0..N)
    // We determined i=0 is Top (depth 0).
    // Loop: length-1 down to 0.

    final children = <RenderBox>[];
    RenderBox? child = firstChild;
    while (child != null) {
      children.add(child);
      child = (child.parentData! as CardStackParentData).nextSibling;
    }

    for (int i = children.length - 1; i >= 0; i--) {
      final child = children[i];
      final depth = i; // 0 is top.

      // Top card (i=0) gets drag offset
      Offset currentDrag = (i == 0) ? _dragOffset : Offset.zero;

      final scale = 1.0 - (depth * (1 - _scaleFactor));
      final childStackOffset = Offset(
        _stackOffset.dx * depth,
        _stackOffset.dy * depth,
      );

      final centerX = size.width / 2;
      final centerY = size.height / 2;

      // Apply rotation based on drag for top card
      double rotation = 0;
      if (i == 0 && _dragOffset.dx != 0) {
        rotation = (_dragOffset.dx / size.width) * 0.2; // slight rotation
      }

      final Matrix4 transform = Matrix4.identity()
        ..translate(Vector3(centerX, centerY, 0.0))
        ..translate(Vector3(currentDrag.dx, currentDrag.dy, 0.0))
        ..rotateZ(rotation)
        ..scale(scale)
        ..translate(Vector3(-centerX, -centerY, 0.0));

      context.pushTransform(
        needsCompositing,
        offset + childStackOffset,
        transform,
        (ctx, off) {
          ctx.paintChild(child, off);
        },
      );
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragOffset += details.delta;
    markNeedsPaint();
  }

  void _handleDragEnd(DragEndDetails details) {
    // Check threshold
    if (_dragOffset.dx.abs() > size.width * 0.4) {
      // Dismiss
      final DismissDirection direction = _dragOffset.dx > 0
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart;

      onSwipe?.call(0, direction);

      // Reset immediately? Or animate out?
      // For "pure render object" manual animation is hard without Ticker.
      // We'll just reset and assume parent rebuilds (removes card).
      _dragOffset = Offset.zero;
      markNeedsPaint();
    } else {
      // Snap back
      _dragOffset = Offset.zero;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}
