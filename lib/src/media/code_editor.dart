import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A code editor widget with syntax highlighting.
class CodeEditor extends LeafRenderObjectWidget {
  const CodeEditor({
    super.key,
    this.code = '',
    this.language = 'dart',
    this.onChanged,
    this.lineNumbers = true,
    this.readOnly = false,
    this.tag,
  });

  final String code;
  final String language;
  final void Function(String code)? onChanged;
  final bool lineNumbers;
  final bool readOnly;
  final String? tag;

  @override
  RenderCodeEditor createRenderObject(BuildContext context) {
    return RenderCodeEditor(
      code: code,
      language: language,
      onChanged: onChanged,
      lineNumbers: lineNumbers,
      readOnly: readOnly,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCodeEditor renderObject) {
    renderObject
      ..code = code
      ..language = language
      ..onChanged = onChanged
      ..lineNumbers = lineNumbers
      ..readOnly = readOnly;
  }
}

class RenderCodeEditor extends RenderBox {
  RenderCodeEditor({
    required String code,
    required String language,
    void Function(String code)? onChanged,
    required bool lineNumbers,
    required bool readOnly,
  }) : _code = code,
       _language = language,
       _onChanged = onChanged,
       _lineNumbers = lineNumbers,
       _readOnly = readOnly {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  String _code;
  set code(String value) {
    if (_code != value) {
      _code = value;
      markNeedsPaint();
    }
  }

  // ignore: unused_field
  String _language;
  set language(String value) {
    _language = value;
    markNeedsPaint();
  }

  // ignore: unused_field
  void Function(String code)? _onChanged;
  set onChanged(void Function(String code)? value) => _onChanged = value;

  bool _lineNumbers;
  set lineNumbers(bool value) {
    if (_lineNumbers != value) {
      _lineNumbers = value;
      markNeedsPaint();
    }
  }

  // ignore: unused_field
  bool _readOnly;
  set readOnly(bool value) => _readOnly = value;

  late TapGestureRecognizer _tap;
  int _cursorLine = 0;

  static const double _lineHeight = 20.0;
  static const double _gutterWidth = 40.0;
  static const double _padding = 12.0;

  // Simple syntax highlighting colors
  static const _keywordColor = Color(0xFF0000FF);
  static const _stringColor = Color(0xFF008000);
  static const _commentColor = Color(0xFF808080);
  static const _numberColor = Color(0xFFFF6600);
  static const _defaultColor = Color(0xFF333333);

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    final lines = _code.split('\n');
    final height = (lines.length * _lineHeight + _padding * 2).clamp(
      100.0,
      400.0,
    );
    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, const Radius.circular(4)),
      Paint()..color = const Color(0xFFF8F8F8),
    );

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFE0E0E0),
    );

    final lines = _code.split('\n');
    final contentX = offset.dx + (_lineNumbers ? _gutterWidth : 0) + _padding;

    // Gutter background
    if (_lineNumbers) {
      canvas.drawRect(
        Rect.fromLTWH(offset.dx, offset.dy, _gutterWidth, size.height),
        Paint()..color = const Color(0xFFEEEEEE),
      );
      canvas.drawLine(
        Offset(offset.dx + _gutterWidth, offset.dy),
        Offset(offset.dx + _gutterWidth, offset.dy + size.height),
        Paint()..color = const Color(0xFFDDDDDD),
      );
    }

    // Current line highlight
    if (_cursorLine < lines.length) {
      canvas.drawRect(
        Rect.fromLTWH(
          offset.dx + (_lineNumbers ? _gutterWidth : 0),
          offset.dy + _padding + _cursorLine * _lineHeight,
          size.width - (_lineNumbers ? _gutterWidth : 0),
          _lineHeight,
        ),
        Paint()..color = const Color(0xFFFFFF99).withValues(alpha: 0.3),
      );
    }

    for (int i = 0; i < lines.length; i++) {
      final y = offset.dy + _padding + i * _lineHeight;

      // Line number
      if (_lineNumbers) {
        textPainter.text = TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
            fontFamily: 'monospace',
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(offset.dx + _gutterWidth - textPainter.width - 8, y + 2),
        );
      }

      // Code with basic highlighting
      final line = lines[i];
      final spans = _highlightLine(line);
      textPainter.text = TextSpan(children: spans);
      textPainter.layout();
      textPainter.paint(canvas, Offset(contentX, y + 2));
    }
  }

  List<TextSpan> _highlightLine(String line) {
    final spans = <TextSpan>[];
    const keywords = [
      'void',
      'int',
      'double',
      'String',
      'bool',
      'var',
      'final',
      'const',
      'class',
      'return',
      'if',
      'else',
      'for',
      'while',
      'import',
      'export',
      'function',
      'let',
    ];

    final words = line.split(RegExp(r'(\s+)'));
    for (final word in words) {
      Color color = _defaultColor;
      if (keywords.contains(word)) {
        color = _keywordColor;
      } else if (word.startsWith("'") || word.startsWith('"')) {
        color = _stringColor;
      } else if (word.startsWith('//')) {
        color = _commentColor;
      } else if (RegExp(r'^\d+$').hasMatch(word)) {
        color = _numberColor;
      }
      spans.add(
        TextSpan(
          text: word,
          style: TextStyle(fontSize: 13, color: color, fontFamily: 'monospace'),
        ),
      );
    }
    return spans;
  }

  void _handleTapUp(TapUpDetails details) {
    final localY = details.localPosition.dy - _padding;
    _cursorLine = (localY / _lineHeight).floor().clamp(
      0,
      _code.split('\n').length - 1,
    );
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    }
  }
}
