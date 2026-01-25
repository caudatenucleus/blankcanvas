import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/rendering/paragraph_primitive.dart';

/// A widget that detects when the user scrolls near the end and triggers a callback.
/// Uses lowest-level RenderObject APIs.
class InfiniteScroll extends MultiChildRenderObjectWidget {
  InfiniteScroll({
    super.key,
    required this.itemCount,
    required this.onLoadMore,
    this.hasMore = true,
    this.threshold = 200.0,
    this.tag,
  }) : super(children: _buildItems(itemCount, hasMore));

  final int itemCount;
  final Future<void> Function() onLoadMore;
  final bool hasMore;
  final double threshold;
  final String? tag;

  static List<Widget> _buildItems(int count, bool hasMore) {
    final List<Widget> items = List.generate(
      count,
      (i) => ParagraphPrimitive(
        key: ValueKey('item_$i'),
        text: TextSpan(
          text: 'Item ${i + 1}',
          style: const TextStyle(fontSize: 14, color: Color(0xFF000000)),
        ),
      ),
    );
    if (hasMore) {
      items.add(
        ParagraphPrimitive(
          key: const ValueKey('loading'),
          text: const TextSpan(
            text: 'Loading...',
            style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
          ),
        ),
      );
    }
    return items;
  }

  @override
  RenderInfiniteScroll createRenderObject(BuildContext context) {
    return RenderInfiniteScroll(
      itemCount: itemCount,
      hasMore: hasMore,
      threshold: threshold,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderInfiniteScroll renderObject,
  ) {
    renderObject
      ..itemCount = itemCount
      ..hasMore = hasMore
      ..threshold = threshold;
  }
}

class InfiniteScrollParentData extends ContainerBoxParentData<RenderBox> {}

class RenderInfiniteScroll extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, InfiniteScrollParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, InfiniteScrollParentData> {
  RenderInfiniteScroll({
    required int itemCount,
    required bool hasMore,
    required double threshold,
  }) : _itemCount = itemCount,
       _hasMore = hasMore,
       _threshold = threshold;

  int _itemCount;
  set itemCount(int value) {
    if (_itemCount != value) {
      _itemCount = value;
      markNeedsLayout();
    }
  }

  bool _hasMore;
  set hasMore(bool value) {
    if (_hasMore != value) {
      _hasMore = value;
      markNeedsLayout();
    }
  }

  // ignore: unused_field
  double _threshold;
  set threshold(double value) => _threshold = value;

  static const double _itemHeight = 48.0;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! InfiniteScrollParentData) {
      child.parentData = InfiniteScrollParentData();
    }
  }

  @override
  void performLayout() {
    final height = (_itemCount + (_hasMore ? 1 : 0)) * _itemHeight;
    final double width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : 300.0;
    size = constraints.constrain(Size(width, height));

    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      child.layout(
        BoxConstraints.tightFor(width: size.width, height: _itemHeight),
        parentUsesSize: true,
      );
      final pd = child.parentData! as InfiniteScrollParentData;
      pd.offset = Offset(0, index * _itemHeight);
      child = pd.nextSibling;
      index++;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final pd = child.parentData! as InfiniteScrollParentData;
      canvas.drawLine(
        offset + Offset(0, (index + 1) * _itemHeight),
        offset + Offset(size.width, (index + 1) * _itemHeight),
        Paint()..color = const Color(0xFFEEEEEE),
      );
      context.paintChild(child, offset + pd.offset);
      child = pd.nextSibling;
      index++;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
