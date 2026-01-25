import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// An org chart node.
class OrgChartNode {
  const OrgChartNode({
    required this.id,
    required this.name,
    this.title,
    this.children = const [],
  });
  final String id;
  final String name;
  final String? title;
  final List<OrgChartNode> children;
}

/// An organizational chart widget.
class OrgChart extends LeafRenderObjectWidget {
  const OrgChart({
    super.key,
    required this.root,
    this.onNodeTap,
    this.nodeColor = const Color(0xFF2196F3),
    this.lineColor = const Color(0xFFBDBDBD),
    this.tag,
  });

  final OrgChartNode root;
  final void Function(OrgChartNode node)? onNodeTap;
  final Color nodeColor;
  final Color lineColor;
  final String? tag;

  @override
  RenderOrgChart createRenderObject(BuildContext context) {
    return RenderOrgChart(
      root: root,
      onNodeTap: onNodeTap,
      nodeColor: nodeColor,
      lineColor: lineColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderOrgChart renderObject) {
    renderObject
      ..root = root
      ..onNodeTap = onNodeTap
      ..nodeColor = nodeColor
      ..lineColor = lineColor;
  }
}

class RenderOrgChart extends RenderBox {
  RenderOrgChart({
    required OrgChartNode root,
    void Function(OrgChartNode node)? onNodeTap,
    required Color nodeColor,
    required Color lineColor,
  }) : _root = root,
       _onNodeTap = onNodeTap,
       _nodeColor = nodeColor,
       _lineColor = lineColor {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  OrgChartNode _root;
  set root(OrgChartNode value) {
    _root = value;
    markNeedsLayout();
  }

  void Function(OrgChartNode node)? _onNodeTap;
  set onNodeTap(void Function(OrgChartNode node)? value) => _onNodeTap = value;

  Color _nodeColor;
  set nodeColor(Color value) {
    _nodeColor = value;
    markNeedsPaint();
  }

  Color _lineColor;
  set lineColor(Color value) {
    _lineColor = value;
    markNeedsPaint();
  }

  late TapGestureRecognizer _tap;
  String? _hoveredId;

  static const double _nodeWidth = 120.0;
  static const double _nodeHeight = 60.0;
  static const double _horizontalSpacing = 20.0;
  static const double _verticalSpacing = 40.0;

  final Map<String, Rect> _nodeRects = {};

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  double _calculateSubtreeWidth(OrgChartNode node) {
    if (node.children.isEmpty) return _nodeWidth;
    double childrenWidth = 0;
    for (final child in node.children) {
      childrenWidth += _calculateSubtreeWidth(child) + _horizontalSpacing;
    }
    return childrenWidth - _horizontalSpacing;
  }

  int _calculateDepth(OrgChartNode node) {
    if (node.children.isEmpty) return 1;
    int maxChildDepth = 0;
    for (final child in node.children) {
      maxChildDepth = maxChildDepth > _calculateDepth(child)
          ? maxChildDepth
          : _calculateDepth(child);
    }
    return 1 + maxChildDepth;
  }

  @override
  void performLayout() {
    _nodeRects.clear();
    final width = _calculateSubtreeWidth(_root);
    final depth = _calculateDepth(_root);
    final height = depth * (_nodeHeight + _verticalSpacing);
    size = constraints.constrain(
      Size(width.clamp(200, constraints.maxWidth), height),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    _paintNode(
      canvas,
      _root,
      offset.dx + size.width / 2 - _nodeWidth / 2,
      offset.dy,
    );
  }

  void _paintNode(Canvas canvas, OrgChartNode node, double x, double y) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final rect = Rect.fromLTWH(x, y, _nodeWidth, _nodeHeight);
    _nodeRects[node.id] = Rect.fromLTWH(
      x,
      y - (size.height > 0 ? 0 : 0),
      _nodeWidth,
      _nodeHeight,
    );

    final isHovered = _hoveredId == node.id;

    // Node box
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()
        ..color = isHovered ? _nodeColor : _nodeColor.withValues(alpha: 0.9),
    );

    // Name
    textPainter.text = TextSpan(
      text: node.name,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFFFFF),
      ),
    );
    textPainter.layout(maxWidth: _nodeWidth - 16);
    textPainter.paint(
      canvas,
      Offset(x + _nodeWidth / 2 - textPainter.width / 2, y + 12),
    );

    // Title
    if (node.title != null) {
      textPainter.text = TextSpan(
        text: node.title,
        style: const TextStyle(fontSize: 10, color: Color(0xDDFFFFFF)),
      );
      textPainter.layout(maxWidth: _nodeWidth - 16);
      textPainter.paint(
        canvas,
        Offset(x + _nodeWidth / 2 - textPainter.width / 2, y + 32),
      );
    }

    // Draw children
    if (node.children.isNotEmpty) {
      final childrenWidth =
          node.children.fold<double>(
            0,
            (sum, c) => sum + _calculateSubtreeWidth(c) + _horizontalSpacing,
          ) -
          _horizontalSpacing;
      double childX = x + _nodeWidth / 2 - childrenWidth / 2;
      final childY = y + _nodeHeight + _verticalSpacing;

      // Vertical line from parent
      canvas.drawLine(
        Offset(x + _nodeWidth / 2, y + _nodeHeight),
        Offset(x + _nodeWidth / 2, y + _nodeHeight + _verticalSpacing / 2),
        Paint()
          ..color = _lineColor
          ..strokeWidth = 2,
      );

      for (final child in node.children) {
        final subtreeWidth = _calculateSubtreeWidth(child);
        final childCenterX = childX + subtreeWidth / 2;

        // Horizontal line to child
        canvas.drawLine(
          Offset(x + _nodeWidth / 2, y + _nodeHeight + _verticalSpacing / 2),
          Offset(childCenterX, y + _nodeHeight + _verticalSpacing / 2),
          Paint()
            ..color = _lineColor
            ..strokeWidth = 2,
        );

        // Vertical line to child
        canvas.drawLine(
          Offset(childCenterX, y + _nodeHeight + _verticalSpacing / 2),
          Offset(childCenterX, childY),
          Paint()
            ..color = _lineColor
            ..strokeWidth = 2,
        );

        _paintNode(canvas, child, childCenterX - _nodeWidth / 2, childY);
        childX += subtreeWidth + _horizontalSpacing;
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (final entry in _nodeRects.entries) {
      if (entry.value.contains(local)) {
        final node = _findNode(_root, entry.key);
        if (node != null) _onNodeTap?.call(node);
        return;
      }
    }
  }

  OrgChartNode? _findNode(OrgChartNode node, String id) {
    if (node.id == id) return node;
    for (final child in node.children) {
      final found = _findNode(child, id);
      if (found != null) return found;
    }
    return null;
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    String? hovered;
    for (final entry in _nodeRects.entries) {
      if (entry.value.contains(local)) {
        hovered = entry.key;
        break;
      }
    }
    if (_hoveredId != hovered) {
      _hoveredId = hovered;
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
