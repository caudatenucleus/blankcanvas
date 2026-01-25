import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A funnel chart stage.
class FunnelStage {
  const FunnelStage({required this.label, required this.value, this.color});
  final String label;
  final double value;
  final Color? color;
}

/// A funnel chart widget.
class FunnelChart extends LeafRenderObjectWidget {
  const FunnelChart({
    super.key,
    required this.stages,
    this.onStageTap,
    this.tag,
  });

  final List<FunnelStage> stages;
  final void Function(FunnelStage stage)? onStageTap;
  final String? tag;

  @override
  RenderFunnelChart createRenderObject(BuildContext context) {
    return RenderFunnelChart(stages: stages, onStageTap: onStageTap);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFunnelChart renderObject,
  ) {
    renderObject
      ..stages = stages
      ..onStageTap = onStageTap;
  }
}

class RenderFunnelChart extends RenderBox {
  RenderFunnelChart({
    required List<FunnelStage> stages,
    void Function(FunnelStage stage)? onStageTap,
  }) : _stages = stages,
       _onStageTap = onStageTap {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<FunnelStage> _stages;
  set stages(List<FunnelStage> value) {
    _stages = value;
    markNeedsPaint();
  }

  void Function(FunnelStage stage)? _onStageTap;
  set onStageTap(void Function(FunnelStage stage)? value) =>
      _onStageTap = value;

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  static const List<Color> _colors = [
    Color(0xFF2196F3),
    Color(0xFF42A5F5),
    Color(0xFF64B5F6),
    Color(0xFF90CAF9),
    Color(0xFFBBDEFB),
  ];

  final List<Path> _stagePaths = [];

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
    _stagePaths.clear();

    if (_stages.isEmpty) return;

    final maxValue = _stages.map((s) => s.value).reduce(math.max);
    final stageHeight = size.height / _stages.length;
    final centerX = offset.dx + size.width / 2;
    final labelWidth = 80.0;
    final funnelWidth = size.width - labelWidth * 2;

    for (int i = 0; i < _stages.length; i++) {
      final stage = _stages[i];
      final topWidth =
          funnelWidth * (i == 0 ? 1 : _stages[i - 1].value / maxValue);
      final bottomWidth = funnelWidth * stage.value / maxValue;
      final y = offset.dy + i * stageHeight;
      final isHovered = _hoveredIndex == i;

      final path = Path()
        ..moveTo(centerX - topWidth / 2, y)
        ..lineTo(centerX + topWidth / 2, y)
        ..lineTo(centerX + bottomWidth / 2, y + stageHeight)
        ..lineTo(centerX - bottomWidth / 2, y + stageHeight)
        ..close();

      _stagePaths.add(path);

      final color = stage.color ?? _colors[i % _colors.length];
      canvas.drawPath(
        path,
        Paint()..color = isHovered ? color : color.withValues(alpha: 0.85),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFFFFFFFF)
          ..strokeWidth = 2,
      );

      // Label on left
      textPainter.text = TextSpan(
        text: stage.label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offset.dx + 8, y + stageHeight / 2 - textPainter.height / 2),
      );

      // Value on right
      textPainter.text = TextSpan(
        text: stage.value.toStringAsFixed(0),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          offset.dx + size.width - textPainter.width - 8,
          y + stageHeight / 2 - textPainter.height / 2,
        ),
      );

      // Percentage
      if (i > 0) {
        final percent = (stage.value / _stages[0].value * 100).toStringAsFixed(
          0,
        );
        textPainter.text = TextSpan(
          text: '$percent%',
          style: const TextStyle(fontSize: 10, color: Color(0xFFFFFFFF)),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            centerX - textPainter.width / 2,
            y + stageHeight / 2 - textPainter.height / 2,
          ),
        );
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final local = details.localPosition;
    for (int i = 0; i < _stagePaths.length; i++) {
      if (_stagePaths[i].contains(local)) {
        _onStageTap?.call(_stages[i]);
        return;
      }
    }
  }

  void _handleHover(PointerHoverEvent event) {
    final local = event.localPosition;
    int? hovered;
    for (int i = 0; i < _stagePaths.length; i++) {
      if (_stagePaths[i].contains(local)) {
        hovered = i;
        break;
      }
    }
    if (_hoveredIndex != hovered) {
      _hoveredIndex = hovered;
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
