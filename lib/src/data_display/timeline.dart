import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;

/// An item in a Timeline.
class TimelineItem {
  const TimelineItem({
    required this.title,
    this.description,
    this.time,
    this.icon,
    this.isActive = false,
  });

  final String title;
  final String? description;
  final String? time;
  final Widget? icon;
  final bool isActive;
}

/// A vertical timeline widget using lowest-level RenderObject APIs.
class Timeline extends MultiChildRenderObjectWidget {
  Timeline({
    super.key,
    required this.items,
    this.connectorColor = const Color(0xFFE0E0E0),
    this.activeColor = const Color(0xFF2196F3),
    this.tag,
  }) : super(
         children: items.map((i) => i.icon ?? const layout.SizedBox()).toList(),
       );

  final List<TimelineItem> items;
  final Color connectorColor;
  final Color activeColor;
  final String? tag;

  @override
  RenderTimeline createRenderObject(BuildContext context) {
    return RenderTimeline(
      items: items,
      connectorColor: connectorColor,
      activeColor: activeColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTimeline renderObject) {
    renderObject
      ..items = items
      ..connectorColor = connectorColor
      ..activeColor = activeColor;
  }
}

class TimelineParentData extends ContainerBoxParentData<RenderBox> {}

class RenderTimeline extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TimelineParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TimelineParentData> {
  RenderTimeline({
    required List<TimelineItem> items,
    required Color connectorColor,
    required Color activeColor,
  }) : _items = items,
       _connectorColor = connectorColor,
       _activeColor = activeColor;

  List<TimelineItem> _items;
  List<TimelineItem> get items => _items;
  set items(List<TimelineItem> value) {
    if (_items == value) return;
    _items = value;
    markNeedsLayout();
  }

  Color _connectorColor;
  set connectorColor(Color value) {
    if (_connectorColor == value) return;
    _connectorColor = value;
    markNeedsPaint();
  }

  Color _activeColor;
  set activeColor(Color value) {
    if (_activeColor == value) return;
    _activeColor = value;
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TimelineParentData) {
      child.parentData = TimelineParentData();
    }
  }

  @override
  void performLayout() {
    double currentY = 0.0;
    double maxW = constraints.maxWidth;
    if (maxW.isInfinite) maxW = 300.0; // Default width

    RenderBox? child = firstChild;
    int i = 0;

    // Config
    const double leftColumnWidth = 32.0;
    const double contentPadding = 12.0;
    final double availableTextWidth = (maxW - leftColumnWidth - contentPadding)
        .clamp(0.0, double.infinity);

    while (child != null && i < _items.length) {
      final TimelineItem item = _items[i];

      // Layout Icon (child)
      // Icon is strictly sized 12x12 in original, but we layout child flexibly inside that constraint?
      // Original: 12x12 container wrapping icon.
      child.layout(
        BoxConstraints(maxWidth: 12, maxHeight: 12),
        parentUsesSize: true,
      );

      // Layout Text to measure height
      final TextPainter titlePainter = TextPainter(
        text: TextSpan(
          text: item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: item.isActive
                ? const Color(0xFF000000)
                : const Color(0xFF666666),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: availableTextWidth);

      double itemHeight = titlePainter.height;

      TextPainter? descPainter;
      if (item.description != null) {
        descPainter = TextPainter(
          text: TextSpan(
            text: item.description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: availableTextWidth);
        itemHeight += 4 + descPainter.height;
      }

      // Minimum height for line connection
      itemHeight = itemHeight < 24.0 ? 24.0 : itemHeight;
      itemHeight += 24.0; // Bottom padding

      // Position Child (Icon)
      // Center of 32 width column?
      // Top 4px margin.
      final TimelineParentData pd = child.parentData! as TimelineParentData;
      pd.offset = Offset(
        (32 - child.size.width) / 2,
        currentY + 4 + (12 - child.size.height) / 2,
      );

      // We don't store text painters, we paint them later.
      // But we need total size.
      // Ideally we shouldn't re-layout text in paint.
      // For this simplified RenderObject, we re-layout or cache?
      // Let's assume re-layout for simplicity/memory trade-off or strict correctness.
      // Text layout is expensive.
      // But `RenderParagraph` does it.
      // We can iterate children in paint and remeasuring is okay if data didn't change?
      // Actually `performLayout` sets `size`. We need total height.

      currentY += itemHeight;
      child = childAfter(child);
      i++;
    }

    size = constraints.constrain(Size(maxW, currentY));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    int i = 0;
    double currentY = 0.0;
    final double maxW = size.width;
    const double leftColumnWidth = 32.0;
    const double contentPadding = 12.0; // Gap
    final double availableTextWidth = (maxW - leftColumnWidth - contentPadding)
        .clamp(0.0, double.infinity);

    final Paint linePaint = Paint();
    final Paint dotFillPaint = Paint()..style = PaintingStyle.fill;
    final Paint dotBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Canvas canvas = context.canvas;

    while (child != null && i < _items.length) {
      final TimelineItem item = _items[i];
      final bool isLast = i == _items.length - 1;

      // Re-measure height (should match layout)
      final TextPainter titlePainter = TextPainter(
        text: TextSpan(
          text: item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: item.isActive
                ? const Color(0xFF000000)
                : const Color(0xFF666666),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: availableTextWidth);

      double textBlockHeight = titlePainter.height;

      TextPainter? descPainter;
      if (item.description != null) {
        descPainter = TextPainter(
          text: TextSpan(
            text: item.description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: availableTextWidth);
        textBlockHeight += 4 + descPainter.height;
      }

      final double itemContentHeight = textBlockHeight < 24.0
          ? 24.0
          : textBlockHeight; // Min content height
      final double totalItemHeight = itemContentHeight + 24.0; // Plus padding

      // Paint Line
      if (!isLast) {
        linePaint.color = _connectorColor;
        canvas.drawRect(
          Rect.fromLTWH(
            offset.dx + 15,
            offset.dy + currentY + 16,
            2,
            totalItemHeight - 12,
          ),
          linePaint,
        );
      }

      // Paint Dot
      final double dotY = offset.dy + currentY + 4;
      final double dotX =
          offset.dx + 10; // 32 width, 12 size -> (32-12)/2 = 10 margin
      final Rect dotRect = Rect.fromLTWH(dotX, dotY, 12, 12);

      dotFillPaint.color = item.isActive
          ? _activeColor
          : const Color(0xFFFFFFFF);
      canvas.drawOval(dotRect, dotFillPaint);

      dotBorderPaint.color = item.isActive ? _activeColor : _connectorColor;
      canvas.drawOval(dotRect, dotBorderPaint);

      // Paint Icon (Child)
      final TimelineParentData pd = child.parentData! as TimelineParentData;
      context.paintChild(
        child,
        offset + Offset(0, currentY) + pd.offset,
      ); // pd.offset is relative to item start Y? No, previously calculated?
      // In layout: `pd.offset = Offset((32 - child.size.width)/2, currentY + 4 + (12-child.size.height)/2);`
      // It included currentY!
      // So just `context.paintChild(child, offset + pd.offset);` NO.
      // Wait, `pd.offset` in `performLayout` was set using `currentY`.
      // `setupParentData` uses `ContainerBoxParentData`. `defaultPaint` uses `offset + childParentData.offset`.
      // So if I set `offset` correctly in layout, I can just call `context.paintChild`.
      // But here I'm iterating `child` manually.
      // So I should verify `pd.offset` is correct relative to `RenderTimeline` origin.
      // Yes, `currentY` was cumulative.

      // Since `pd.offset` is relative to parent, I don't need `offset + Offset(0, currentY)`.
      // Just `offset + pd.offset`.
      // EXCEPT I am iterating manually and `pd.offset` was set.
      // Does `context.paintChild` use `pd.offset` automatically? NO.
      // `defaultPaint` does. explicit `paintChild` requires `offset`.

      context.paintChild(child, offset + pd.offset);

      // Paint Text
      final double textX = offset.dx + 32 + 12; // 32 col + 12 padding
      titlePainter.paint(canvas, Offset(textX, offset.dy + currentY));

      // Time?
      if (item.time != null) {
        final TextPainter timePainter = TextPainter(
          text: TextSpan(
            text: item.time,
            style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        // Align right?
        // Original: Row with MainAxisAlignment.spaceBetween.
        // So TextX + availableTextWidth - timeWidth?
        // Actually `availableTextWidth` was constrained max.
        // If we want spaceBetween, we put time at far right edge.
        final double timeX =
            offset.dx + maxW - contentPadding - timePainter.width;
        timePainter.paint(
          canvas,
          Offset(timeX, offset.dy + currentY + 2),
        ); // +2 baseline adjust?
      }

      if (descPainter != null) {
        descPainter.paint(
          canvas,
          Offset(textX, offset.dy + currentY + titlePainter.height + 4),
        );
      }

      currentY += totalItemHeight;
      child = childAfter(child);
      i++;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
