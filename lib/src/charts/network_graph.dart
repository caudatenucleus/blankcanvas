import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A network graph node.
class NetworkNode {
  const NetworkNode({
    required this.id,
    required this.label,
    this.x,
    this.y,
    this.color,
  });
  final String id;
  final String label;
  final double? x;
  final double? y;
  final Color? color;
}

/// A network graph edge.
class NetworkEdge {
  const NetworkEdge({required this.from, required this.to, this.weight = 1});
  final String from;
  final String to;
  final double weight;
}

/// A network graph widget.
class NetworkGraph extends LeafRenderObjectWidget {
  const NetworkGraph({
    super.key,
    required this.nodes,
    required this.edges,
    this.onNodeTap,
    this.nodeColor = const Color(0xFF2196F3),
    this.edgeColor = const Color(0xFFBDBDBD),
    this.tag,
  });

  final List<NetworkNode> nodes;
  final List<NetworkEdge> edges;
  final void Function(NetworkNode node)? onNodeTap;
  final Color nodeColor;
  final Color edgeColor;
  final String? tag;

  @override
  RenderNetworkGraph createRenderObject(BuildContext context) {
    return RenderNetworkGraph(
      nodes: nodes,
      edges: edges,
      onNodeTap: onNodeTap,
      nodeColor: nodeColor,
      edgeColor: edgeColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderNetworkGraph renderObject,
  ) {
    renderObject
      ..nodes = nodes
      ..edges = edges
      ..onNodeTap = onNodeTap
      ..nodeColor = nodeColor
      ..edgeColor = edgeColor;
  }
}

class RenderNetworkGraph extends RenderBox {
  RenderNetworkGraph({
    required List<NetworkNode> nodes,
    required List<NetworkEdge> edges,
    void Function(NetworkNode node)? onNodeTap,
    required Color nodeColor,
    required Color edgeColor,
  }) : _nodes = nodes,
       _edges = edges,
       _onNodeTap = onNodeTap,
       _nodeColor = nodeColor,
       _edgeColor = edgeColor {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
    _calculatePositions();
  }

  List<NetworkNode> _nodes;
  set nodes(List<NetworkNode> value) {
    _nodes = value;
    _calculatePositions();
  }

  List<NetworkEdge> _edges;
  set edges(List<NetworkEdge> value) {
    _edges = value;
    markNeedsPaint();
  }

  void Function(NetworkNode node)? _onNodeTap;
  set onNodeTap(void Function(NetworkNode node)? value) => _onNodeTap = value;

  Color _nodeColor;
  set nodeColor(Color value) => _nodeColor = value;

  Color _edgeColor;
  set edgeColor(Color value) => _edgeColor = value;

  late TapGestureRecognizer _tap;
  String? _hoveredId;

  final Map<String, Offset> _nodePositions = {};
  static const double _nodeRadius = 24.0;

  void _calculatePositions() {
    _nodePositions.clear();
    if (_nodes.isEmpty) return;

    // Simple circular layout for nodes without positions
    for (int i = 0; i < _nodes.length; i++) {
      final node = _nodes[i];
      if (node.x != null && node.y != null) {
        _nodePositions[node.id] = Offset(node.x!, node.y!);
      } else {
        final angle = 2 * math.pi * i / _nodes.length - math.pi / 2;
        _nodePositions[node.id] = Offset(
          0.5 + 0.35 * math.cos(angle),
          0.5 + 0.35 * math.sin(angle),
        );
      }
    }
    markNeedsPaint();
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, 300));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw edges
    for (final edge in _edges) {
      final fromPos = _nodePositions[edge.from];
      final toPos = _nodePositions[edge.to];
      if (fromPos == null || toPos == null) continue;

      final from =
          offset + Offset(fromPos.dx * size.width, fromPos.dy * size.height);
      final to = offset + Offset(toPos.dx * size.width, toPos.dy * size.height);

      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = _edgeColor
          ..strokeWidth = edge.weight.clamp(1, 5),
      );
    }

    // Draw nodes
    for (final node in _nodes) {
      final pos = _nodePositions[node.id];
      if (pos == null) continue;

      final center = offset + Offset(pos.dx * size.width, pos.dy * size.height);
      final isHovered = _hoveredId == node.id;
      final color = node.color ?? _nodeColor;

      // Node circle
      canvas.drawCircle(
        center,
        _nodeRadius,
        Paint()..color = isHovered ? color : color.withValues(alpha: 0.9),
      );

      // Label
      textPainter.text = TextSpan(
        text: node.label,
        style: const TextStyle(fontSize: 10, color: Color(0xFFFFFFFF)),
      );
      textPainter.layout(maxWidth: _nodeRadius * 2 - 4);
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (final node in _nodes) {
      final pos = _nodePositions[node.id];
      if (pos == null) continue;
      final center = Offset(pos.dx * size.width, pos.dy * size.height);
      if ((local - center).distance <= _nodeRadius) {
        _onNodeTap?.call(node);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    String? hovered;
    for (final node in _nodes) {
      final pos = _nodePositions[node.id];
      if (pos == null) continue;
      final center = Offset(pos.dx * size.width, pos.dy * size.height);
      if ((local - center).distance <= _nodeRadius) {
        hovered = node.id;
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
