import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Result status type.
enum ResultStatus { success, error, warning, info }

/// A result display widget for success/error states.
class Result extends SingleChildRenderObjectWidget {
  const Result({
    super.key,
    required this.status,
    required this.title,
    this.subtitle,
    super.child,
    this.tag,
  });

  final ResultStatus status;
  final String title;
  final String? subtitle;
  final String? tag;

  @override
  RenderResult createRenderObject(BuildContext context) {
    return RenderResult(status: status, title: title, subtitle: subtitle);
  }

  @override
  void updateRenderObject(BuildContext context, RenderResult renderObject) {
    renderObject
      ..status = status
      ..title = title
      ..subtitle = subtitle;
  }
}

class RenderResult extends RenderProxyBox {
  RenderResult({
    required ResultStatus status,
    required String title,
    String? subtitle,
  }) : _status = status,
       _title = title,
       _subtitle = subtitle;

  ResultStatus _status;
  set status(ResultStatus value) {
    if (_status != value) {
      _status = value;
      markNeedsPaint();
    }
  }

  String _title;
  set title(String value) {
    if (_title != value) {
      _title = value;
      markNeedsPaint();
    }
  }

  String? _subtitle;
  set subtitle(String? value) {
    if (_subtitle != value) {
      _subtitle = value;
      markNeedsPaint();
    }
  }

  Color get _statusColor {
    switch (_status) {
      case ResultStatus.success:
        return const Color(0xFF4CAF50);
      case ResultStatus.error:
        return const Color(0xFFE53935);
      case ResultStatus.warning:
        return const Color(0xFFFF9800);
      case ResultStatus.info:
        return const Color(0xFF2196F3);
    }
  }

  String get _statusIcon {
    switch (_status) {
      case ResultStatus.success:
        return '✓';
      case ResultStatus.error:
        return '✕';
      case ResultStatus.warning:
        return '!';
      case ResultStatus.info:
        return 'i';
    }
  }

  static const double _iconSize = 64.0;
  static const double _topPadding = 40.0;

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      size = constraints.constrain(
        Size(
          constraints.maxWidth,
          _topPadding + _iconSize + 80 + child!.size.height,
        ),
      );
    } else {
      size = constraints.constrain(
        Size(constraints.maxWidth, _topPadding + _iconSize + 80),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final centerX = offset.dx + size.width / 2;

    // Icon circle
    final iconCenter = Offset(centerX, offset.dy + _topPadding + _iconSize / 2);
    canvas.drawCircle(
      iconCenter,
      _iconSize / 2,
      Paint()..color = _statusColor.withValues(alpha: 0.15),
    );
    canvas.drawCircle(
      iconCenter,
      _iconSize / 2 - 4,
      Paint()..color = _statusColor,
    );

    // Icon
    textPainter.text = TextSpan(
      text: _statusIcon,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFFFFFF),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      iconCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Title
    final titleY = offset.dy + _topPadding + _iconSize + 20;
    textPainter.text = TextSpan(
      text: _title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, titleY));

    // Subtitle
    if (_subtitle != null) {
      textPainter.text = TextSpan(
        text: _subtitle,
        style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
      );
      textPainter.layout(maxWidth: size.width - 40);
      textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2, titleY + 36),
      );
    }

    // Child actions
    if (child != null) {
      final childY = _topPadding + _iconSize + 80;
      context.paintChild(
        child!,
        Offset(centerX - child!.size.width / 2, offset.dy + childY),
      );
    }
  }
}
