import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A flow chart node type.
enum FlowChartNodeType { start, end, process, decision, io }

/// A flow chart node.
class FlowChartNode {
  const FlowChartNode({
    required this.id,
    required this.label,
    this.type = FlowChartNodeType.process,
    this.x = 0,
    this.y = 0,
  });
  final String id;
  final String label;
  final FlowChartNodeType type;
  final double x;
  final double y;
}

/// A flow chart connection.
class FlowChartConnection {
  const FlowChartConnection({required this.from, required this.to, this.label});
  final String from;
  final String to;
  final String? label;
}

/// A flow chart widget.
class FlowChart extends LeafRenderObjectWidget {
  const FlowChart({
    super.key,
    required this.nodes,
    required this.connections,
    this.onNodeTap,
    this.tag,
  });

  final List<FlowChartNode> nodes;
  final List<FlowChartConnection> connections;
  final void Function(FlowChartNode node)? onNodeTap;
  final String? tag;

  @override
  RenderFlowChart createRenderObject(BuildContext context) {
    return RenderFlowChart(
      nodes: nodes,
      connections: connections,
      onNodeTap: onNodeTap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFlowChart renderObject) {
    renderObject
      ..nodes = nodes
      ..connections = connections
      ..onNodeTap = onNodeTap;
  }
}

class RenderFlowChart extends RenderBox {
  RenderFlowChart({
    required List<FlowChartNode> nodes,
    required List<FlowChartConnection> connections,
    void Function(FlowChartNode node)? onNodeTap,
  }) : _nodes = nodes,
       _connections = connections,
       _onNodeTap = onNodeTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<FlowChartNode> _nodes;
  set nodes(List<FlowChartNode> value) {
    _nodes = value;
    markNeedsPaint();
  }

  List<FlowChartConnection> _connections;
  set connections(List<FlowChartConnection> value) {
    _connections = value;
    markNeedsPaint();
  }

  void Function(FlowChartNode node)? _onNodeTap;
  set onNodeTap(void Function(FlowChartNode node)? value) => _onNodeTap = value;

  late TapGestureRecognizer _tap;
  String? _hoveredId;

  static const double _nodeWidth = 100.0;
  static const double _nodeHeight = 50.0;

  final Map<String, Rect> _nodeRects = {};

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _nodeRects.clear();
    size = constraints.constrain(
      Size(constraints.maxWidth, constraints.maxHeight.clamp(200, 500)),
    );
  }

  Offset _getNodeCenter(FlowChartNode node) {
    return Offset(
      node.x * size.width / 100 + _nodeWidth / 2,
      node.y * size.height / 100 + _nodeHeight / 2,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw connections first
    for (final conn in _connections) {
      final fromNode = _nodes.where((n) => n.id == conn.from).firstOrNull;
      final toNode = _nodes.where((n) => n.id == conn.to).firstOrNull;
      if (fromNode == null || toNode == null) continue;

      final from = offset + _getNodeCenter(fromNode);
      final to = offset + _getNodeCenter(toNode);

      // Arrow line
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = const Color(0xFF666666)
          ..strokeWidth = 2,
      );

      // Arrowhead
      final angle = (to - from).direction;
      final arrowSize = 10.0;
      final arrowPoint = to - Offset.fromDirection(angle, _nodeHeight / 2 + 5);
      final arrow = Path()
        ..moveTo(arrowPoint.dx, arrowPoint.dy)
        ..lineTo(
          arrowPoint.dx - arrowSize * math.cos(angle - 0.4),
          arrowPoint.dy - arrowSize * math.sin(angle - 0.4),
        )
        ..lineTo(
          arrowPoint.dx - arrowSize * math.cos(angle + 0.4),
          arrowPoint.dy - arrowSize * math.sin(angle + 0.4),
        )
        ..close();
      canvas.drawPath(arrow, Paint()..color = const Color(0xFF666666));

      // Connection label
      if (conn.label != null) {
        textPainter.text = TextSpan(
          text: conn.label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
        );
        textPainter.layout();
        final mid = (from + to) / 2;
        textPainter.paint(
          canvas,
          mid - Offset(textPainter.width / 2, textPainter.height / 2 + 10),
        );
      }
    }

    // Draw nodes
    for (final node in _nodes) {
      final x = offset.dx + node.x * size.width / 100;
      final y = offset.dy + node.y * size.height / 100;
      final isHovered = _hoveredId == node.id;

      _nodeRects[node.id] = Rect.fromLTWH(
        node.x * size.width / 100,
        node.y * size.height / 100,
        _nodeWidth,
        _nodeHeight,
      );

      Color color;
      switch (node.type) {
        case FlowChartNodeType.start:
          color = const Color(0xFF4CAF50);
          break;
        case FlowChartNodeType.end:
          color = const Color(0xFFE53935);
          break;
        case FlowChartNodeType.decision:
          color = const Color(0xFFFF9800);
          break;
        case FlowChartNodeType.io:
          color = const Color(0xFF9C27B0);
          break;
        default:
          color = const Color(0xFF2196F3);
      }

      Path shapePath;
      switch (node.type) {
        case FlowChartNodeType.start:
        case FlowChartNodeType.end:
          // Rounded rect / stadium
          shapePath = Path()
            ..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, _nodeWidth, _nodeHeight),
                const Radius.circular(25),
              ),
            );
          break;
        case FlowChartNodeType.decision:
          // Diamond
          shapePath = Path()
            ..moveTo(x + _nodeWidth / 2, y)
            ..lineTo(x + _nodeWidth, y + _nodeHeight / 2)
            ..lineTo(x + _nodeWidth / 2, y + _nodeHeight)
            ..lineTo(x, y + _nodeHeight / 2)
            ..close();
          break;
        case FlowChartNodeType.io:
          // Parallelogram
          final skew = 15.0;
          shapePath = Path()
            ..moveTo(x + skew, y)
            ..lineTo(x + _nodeWidth, y)
            ..lineTo(x + _nodeWidth - skew, y + _nodeHeight)
            ..lineTo(x, y + _nodeHeight)
            ..close();
          break;
        default:
          // Rectangle
          shapePath = Path()
            ..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, _nodeWidth, _nodeHeight),
                const Radius.circular(4),
              ),
            );
      }

      canvas.drawPath(
        shapePath,
        Paint()..color = isHovered ? color : color.withValues(alpha: 0.9),
      );

      // Label
      textPainter.text = TextSpan(
        text: node.label,
        style: const TextStyle(fontSize: 11, color: Color(0xFFFFFFFF)),
      );
      textPainter.layout(maxWidth: _nodeWidth - 10);
      textPainter.paint(
        canvas,
        Offset(
          x + _nodeWidth / 2 - textPainter.width / 2,
          y + _nodeHeight / 2 - textPainter.height / 2,
        ),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (final entry in _nodeRects.entries) {
      if (entry.value.contains(local)) {
        final node = _nodes.firstWhere((n) => n.id == entry.key);
        _onNodeTap?.call(node);
        return;
      }
    }
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
