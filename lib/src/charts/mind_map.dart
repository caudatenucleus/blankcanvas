import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A mind map node.
class MindMapNode {
  const MindMapNode({
    required this.id,
    required this.text,
    this.children = const [],
    this.color,
  });
  final String id;
  final String text;
  final List<MindMapNode> children;
  final Color? color;
}

/// A mind map visualization widget.
class MindMap extends LeafRenderObjectWidget {
  const MindMap({super.key, required this.root, this.onNodeTap, this.tag});

  final MindMapNode root;
  final void Function(MindMapNode node)? onNodeTap;
  final String? tag;

  @override
  RenderMindMap createRenderObject(BuildContext context) {
    return RenderMindMap(root: root, onNodeTap: onNodeTap);
  }

  @override
  void updateRenderObject(BuildContext context, RenderMindMap renderObject) {
    renderObject
      ..root = root
      ..onNodeTap = onNodeTap;
  }
}

class RenderMindMap extends RenderBox {
  RenderMindMap({
    required MindMapNode root,
    void Function(MindMapNode node)? onNodeTap,
  }) : _root = root,
       _onNodeTap = onNodeTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  MindMapNode _root;
  set root(MindMapNode value) {
    _root = value;
    markNeedsLayout();
  }

  void Function(MindMapNode node)? _onNodeTap;
  set onNodeTap(void Function(MindMapNode node)? value) => _onNodeTap = value;

  late TapGestureRecognizer _tap;
  String? _hoveredId;

  final Map<String, Rect> _nodeRects = {};

  static const double _nodeHeight = 32.0;
  static const double _nodeMinWidth = 80.0;
  static const double _levelSpacing = 120.0;
  static const double _nodeSpacing = 10.0;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
  ];

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    _nodeRects.clear();
    size = constraints.constrain(
      Size(constraints.maxWidth, constraints.maxHeight.clamp(300, 600)),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final center = offset + Offset(size.width / 2, size.height / 2);

    // Draw root
    _paintNode(canvas, _root, center, 0, 0, _colors[0]);

    // Draw children in a radial pattern
    if (_root.children.isNotEmpty) {
      final angleStep = math.pi * 2 / _root.children.length;
      for (int i = 0; i < _root.children.length; i++) {
        final angle = -math.pi / 2 + angleStep * i;
        final child = _root.children[i];
        final childPos =
            center +
            Offset(
              math.cos(angle) * _levelSpacing,
              math.sin(angle) * _levelSpacing,
            );
        final color = child.color ?? _colors[(i + 1) % _colors.length];

        // Connection curve
        final controlPoint = Offset(
          (center.dx + childPos.dx) / 2,
          (center.dy + childPos.dy) / 2,
        );
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..quadraticBezierTo(
            controlPoint.dx,
            controlPoint.dy,
            childPos.dx,
            childPos.dy,
          );
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withValues(alpha: 0.5)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );

        _paintNode(canvas, child, childPos, 1, i, color);
        _paintBranch(canvas, child, childPos, angle, 2, color);
      }
    }
  }

  void _paintBranch(
    Canvas canvas,
    MindMapNode parent,
    Offset parentPos,
    double parentAngle,
    int level,
    Color baseColor,
  ) {
    if (parent.children.isEmpty || level > 3) return;

    final spreadAngle = math.pi / 4;
    final startAngle = parentAngle - spreadAngle / 2;
    final angleStep = spreadAngle / math.max(parent.children.length - 1, 1);

    for (int i = 0; i < parent.children.length; i++) {
      final child = parent.children[i];
      final angle = parent.children.length == 1
          ? parentAngle
          : startAngle + angleStep * i;
      final distance = _levelSpacing * (1 - level * 0.15);
      final childPos =
          parentPos +
          Offset(math.cos(angle) * distance, math.sin(angle) * distance);

      // Connection
      canvas.drawLine(
        parentPos,
        childPos,
        Paint()
          ..color = baseColor.withValues(alpha: 0.3)
          ..strokeWidth = 1.5,
      );

      _paintNode(canvas, child, childPos, level, i, baseColor);
      _paintBranch(canvas, child, childPos, angle, level + 1, baseColor);
    }
  }

  void _paintNode(
    Canvas canvas,
    MindMapNode node,
    Offset pos,
    int level,
    int index,
    Color color,
  ) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: node.text,
      style: const TextStyle(fontSize: 11, color: Color(0xFFFFFFFF)),
    );
    textPainter.layout();

    final width = math.max(_nodeMinWidth - level * 10, textPainter.width + 16);
    final height = _nodeHeight - level * 4;
    final rect = Rect.fromCenter(center: pos, width: width, height: height);

    _nodeRects[node.id] = Rect.fromCenter(
      center: Offset(
        pos.dx - (size.width / 2 - constraints.maxWidth / 2),
        pos.dy - (size.height / 2 - constraints.maxHeight / 2) / 2,
      ),
      width: width,
      height: height,
    );

    final isHovered = _hoveredId == node.id;
    final isRoot = level == 0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(isRoot ? 8 : 16)),
      Paint()..color = isHovered ? color : color.withValues(alpha: 0.85),
    );

    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );
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

  MindMapNode? _findNode(MindMapNode node, String id) {
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
