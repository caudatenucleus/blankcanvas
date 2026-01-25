import 'dart:convert';
import 'package:flutter/widgets.dart';

/// Captures and serializes application state for persistence or debugging.
class StateSnapshotter {
  /// Serializes a state map to JSON string.
  static String snapshot(Map<String, dynamic> state) {
    return jsonEncode(state);
  }

  /// Deserializes a JSON string to a state map.
  static Map<String, dynamic> restore(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

/// Custom performance metrics overlay using LeafRenderObjectWidget.
/// Paints frame timing info directly to the canvas.
class PerformanceOverlay extends LeafRenderObjectWidget {
  const PerformanceOverlay({
    super.key,
    this.showFps = true,
    this.showMemory = false,
  });

  final bool showFps;
  final bool showMemory;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderPerformanceOverlay(showFps: showFps, showMemory: showMemory);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPerformanceOverlay renderObject,
  ) {
    renderObject
      ..showFps = showFps
      ..showMemory = showMemory;
  }
}

class RenderPerformanceOverlay extends RenderBox {
  RenderPerformanceOverlay({required bool showFps, required bool showMemory})
    : _showFps = showFps,
      _showMemory = showMemory;

  bool _showFps;
  set showFps(bool v) {
    if (_showFps != v) {
      _showFps = v;
      markNeedsPaint();
    }
  }

  bool _showMemory;
  set showMemory(bool v) {
    if (_showMemory != v) {
      _showMemory = v;
      markNeedsPaint();
    }
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, 24.0);
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;

    // Background
    canvas.drawRect(offset & size, Paint()..color = const Color(0xCC000000));

    // Text content (simulated - in real impl, use TextPainter)
    final textPainter = TextPainter(
      text: TextSpan(
        text: _showFps ? 'FPS: 60 | ' : '',
        style: const TextStyle(color: Color(0xFF00FF00), fontSize: 12),
        children: [
          if (_showMemory)
            const TextSpan(
              text: 'MEM: 128MB',
              style: TextStyle(color: Color(0xFFFFFF00)),
            ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.width);
    textPainter.paint(canvas, offset + const Offset(8, 4));
  }
}
