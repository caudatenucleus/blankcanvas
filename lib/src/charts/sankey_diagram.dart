import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A Sankey diagram link.
class SankeyLink {
  const SankeyLink({
    required this.source,
    required this.target,
    required this.value,
  });
  final String source;
  final String target;
  final double value;
}

/// A Sankey diagram widget.
class SankeyDiagram extends LeafRenderObjectWidget {
  const SankeyDiagram({
    super.key,
    required this.links,
    this.onLinkTap,
    this.tag,
  });

  final List<SankeyLink> links;
  final void Function(SankeyLink link)? onLinkTap;
  final String? tag;

  @override
  RenderSankeyDiagram createRenderObject(BuildContext context) {
    return RenderSankeyDiagram(links: links, onLinkTap: onLinkTap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSankeyDiagram renderObject,
  ) {
    renderObject
      ..links = links
      ..onLinkTap = onLinkTap;
  }
}

class RenderSankeyDiagram extends RenderBox {
  RenderSankeyDiagram({
    required List<SankeyLink> links,
    void Function(SankeyLink link)? onLinkTap,
  }) : _links = links,
       _onLinkTap = onLinkTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<SankeyLink> _links;
  set links(List<SankeyLink> value) {
    _links = value;
    markNeedsLayout();
  }

  void Function(SankeyLink link)? _onLinkTap;
  set onLinkTap(void Function(SankeyLink link)? value) => _onLinkTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredLink;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
  ];

  final List<Path> _linkPaths = [];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _linkPaths.clear();
    size = constraints.constrain(Size(constraints.maxWidth, 250));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (_links.isEmpty) return;

    // Extract nodes
    final sources = <String>{};
    final targets = <String>{};
    for (final link in _links) {
      sources.add(link.source);
      targets.add(link.target);
    }
    final leftNodes = sources.toList();
    final rightNodes = targets.toList();

    // Calculate positions
    final nodeWidth = 20.0;
    final leftX = offset.dx + 50;
    final rightX = offset.dx + size.width - 50 - nodeWidth;
    final chartHeight = size.height - 40;

    // Left node positions
    final leftTotal = _links.fold<double>(0, (sum, l) => sum + l.value);
    final leftNodeHeights = <String, double>{};
    final leftNodeY = <String, double>{};
    double leftY = offset.dy + 20;
    for (final node in leftNodes) {
      final nodeValue = _links
          .where((l) => l.source == node)
          .fold<double>(0, (sum, l) => sum + l.value);
      final height = (nodeValue / leftTotal) * chartHeight;
      leftNodeHeights[node] = height;
      leftNodeY[node] = leftY;
      leftY += height + 5;
    }

    // Right node positions
    final rightTotal = _links.fold<double>(0, (sum, l) => sum + l.value);
    final rightNodeHeights = <String, double>{};
    final rightNodeY = <String, double>{};
    double rightY = offset.dy + 20;
    for (final node in rightNodes) {
      final nodeValue = _links
          .where((l) => l.target == node)
          .fold<double>(0, (sum, l) => sum + l.value);
      final height = (nodeValue / rightTotal) * chartHeight;
      rightNodeHeights[node] = height;
      rightNodeY[node] = rightY;
      rightY += height + 5;
    }

    // Draw links
    final leftOffsets = <String, double>{};
    final rightOffsets = <String, double>{};
    for (final node in leftNodes) {
      leftOffsets[node] = 0;
    }
    for (final node in rightNodes) {
      rightOffsets[node] = 0;
    }

    for (int i = 0; i < _links.length; i++) {
      final link = _links[i];
      final linkHeight = (link.value / leftTotal) * chartHeight;
      final isHovered = _hoveredLink == i;

      final fromY = leftNodeY[link.source]! + (leftOffsets[link.source] ?? 0);
      final toY = rightNodeY[link.target]! + (rightOffsets[link.target] ?? 0);

      leftOffsets[link.source] = (leftOffsets[link.source] ?? 0) + linkHeight;
      rightOffsets[link.target] = (rightOffsets[link.target] ?? 0) + linkHeight;

      final path = Path()
        ..moveTo(leftX + nodeWidth, fromY)
        ..cubicTo(
          leftX + nodeWidth + (rightX - leftX - nodeWidth) / 3,
          fromY,
          rightX - (rightX - leftX - nodeWidth) / 3,
          toY,
          rightX,
          toY,
        )
        ..lineTo(rightX, toY + linkHeight)
        ..cubicTo(
          rightX - (rightX - leftX - nodeWidth) / 3,
          toY + linkHeight,
          leftX + nodeWidth + (rightX - leftX - nodeWidth) / 3,
          fromY + linkHeight,
          leftX + nodeWidth,
          fromY + linkHeight,
        )
        ..close();

      _linkPaths.add(path);

      final color = _colors[i % _colors.length];
      canvas.drawPath(
        path,
        Paint()..color = (isHovered ? color : color.withValues(alpha: 0.6)),
      );
    }

    // Draw nodes
    for (int i = 0; i < leftNodes.length; i++) {
      final node = leftNodes[i];
      final y = leftNodeY[node]!;
      final height = leftNodeHeights[node]!;
      canvas.drawRect(
        Rect.fromLTWH(leftX, y, nodeWidth, height),
        Paint()..color = const Color(0xFF333333),
      );

      textPainter.text = TextSpan(
        text: node,
        style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftX - textPainter.width - 4,
          y + height / 2 - textPainter.height / 2,
        ),
      );
    }

    for (int i = 0; i < rightNodes.length; i++) {
      final node = rightNodes[i];
      final y = rightNodeY[node]!;
      final height = rightNodeHeights[node]!;
      canvas.drawRect(
        Rect.fromLTWH(rightX, y, nodeWidth, height),
        Paint()..color = const Color(0xFF333333),
      );

      textPainter.text = TextSpan(
        text: node,
        style: const TextStyle(fontSize: 10, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rightX + nodeWidth + 4, y + height / 2 - textPainter.height / 2),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _linkPaths.length; i++) {
      if (_linkPaths[i].contains(local)) {
        _onLinkTap?.call(_links[i]);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _linkPaths.length; i++) {
      if (_linkPaths[i].contains(local)) {
        hovered = i;
        break;
      }
    }
    if (_hoveredLink != hovered) {
      _hoveredLink = hovered;
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
