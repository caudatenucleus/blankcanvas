import 'package:flutter/widgets.dart';

/// A diff viewer widget.
class DiffViewer extends LeafRenderObjectWidget {
  const DiffViewer({
    super.key,
    required this.oldText,
    required this.newText,
    this.showLineNumbers = true,
    this.tag,
  });

  final String oldText;
  final String newText;
  final bool showLineNumbers;
  final String? tag;

  @override
  RenderDiffViewer createRenderObject(BuildContext context) {
    return RenderDiffViewer(
      oldText: oldText,
      newText: newText,
      showLineNumbers: showLineNumbers,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderDiffViewer renderObject) {
    renderObject
      ..oldText = oldText
      ..newText = newText
      ..showLineNumbers = showLineNumbers;
  }
}

class RenderDiffViewer extends RenderBox {
  RenderDiffViewer({
    required String oldText,
    required String newText,
    required bool showLineNumbers,
  }) : _oldText = oldText,
       _newText = newText,
       _showLineNumbers = showLineNumbers {
    _computeDiff();
  }

  String _oldText;
  set oldText(String value) {
    _oldText = value;
    _computeDiff();
  }

  String _newText;
  set newText(String value) {
    _newText = value;
    _computeDiff();
  }

  bool _showLineNumbers;
  set showLineNumbers(bool value) {
    _showLineNumbers = value;
    markNeedsPaint();
  }

  final List<_DiffLine> _diffLines = [];

  static const double _lineHeight = 20.0;
  static const double _lineNumberWidth = 40.0;

  void _computeDiff() {
    _diffLines.clear();
    final oldLines = _oldText.split('\n');
    final newLines = _newText.split('\n');

    // Simple line-by-line diff
    int oldIdx = 0;
    int newIdx = 0;

    while (oldIdx < oldLines.length || newIdx < newLines.length) {
      if (oldIdx >= oldLines.length) {
        _diffLines.add(
          _DiffLine(newLines[newIdx], _DiffType.added, null, newIdx + 1),
        );
        newIdx++;
      } else if (newIdx >= newLines.length) {
        _diffLines.add(
          _DiffLine(oldLines[oldIdx], _DiffType.removed, oldIdx + 1, null),
        );
        oldIdx++;
      } else if (oldLines[oldIdx] == newLines[newIdx]) {
        _diffLines.add(
          _DiffLine(
            oldLines[oldIdx],
            _DiffType.unchanged,
            oldIdx + 1,
            newIdx + 1,
          ),
        );
        oldIdx++;
        newIdx++;
      } else {
        _diffLines.add(
          _DiffLine(oldLines[oldIdx], _DiffType.removed, oldIdx + 1, null),
        );
        _diffLines.add(
          _DiffLine(newLines[newIdx], _DiffType.added, null, newIdx + 1),
        );
        oldIdx++;
        newIdx++;
      }
    }

    markNeedsLayout();
  }

  @override
  void performLayout() {
    final height = _diffLines.length * _lineHeight + 20;
    size = constraints.constrain(
      Size(constraints.maxWidth, height.clamp(100, 400)),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFAFAFA),
    );

    final codeX = offset.dx + (_showLineNumbers ? _lineNumberWidth * 2 + 8 : 8);

    for (int i = 0; i < _diffLines.length; i++) {
      final line = _diffLines[i];
      final y = offset.dy + i * _lineHeight;

      if (y > offset.dy + size.height) break;

      // Line background
      Color bgColor;
      String prefix;
      switch (line.type) {
        case _DiffType.added:
          bgColor = const Color(0xFFE6FFED);
          prefix = '+';
          break;
        case _DiffType.removed:
          bgColor = const Color(0xFFFFEBEE);
          prefix = '-';
          break;
        default:
          bgColor = const Color(0x00000000);
          prefix = ' ';
      }

      canvas.drawRect(
        Rect.fromLTWH(offset.dx, y, size.width, _lineHeight),
        Paint()..color = bgColor,
      );

      // Line numbers
      if (_showLineNumbers) {
        // Old line number
        if (line.oldLineNumber != null) {
          textPainter.text = TextSpan(
            text: '${line.oldLineNumber}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(offset.dx + _lineNumberWidth - textPainter.width - 4, y + 2),
          );
        }

        // New line number
        if (line.newLineNumber != null) {
          textPainter.text = TextSpan(
            text: '${line.newLineNumber}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              offset.dx + _lineNumberWidth * 2 - textPainter.width - 4,
              y + 2,
            ),
          );
        }
      }

      // Prefix
      textPainter.text = TextSpan(
        text: prefix,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: line.type == _DiffType.added
              ? const Color(0xFF4CAF50)
              : (line.type == _DiffType.removed
                    ? const Color(0xFFE53935)
                    : const Color(0xFF999999)),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(codeX - 16, y + 2));

      // Code content
      textPainter.text = TextSpan(
        text: line.text,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          color: Color(0xFF333333),
        ),
      );
      textPainter.layout(maxWidth: size.width - codeX - 8);
      textPainter.paint(canvas, Offset(codeX, y + 2));
    }
  }
}

enum _DiffType { added, removed, unchanged }

class _DiffLine {
  _DiffLine(this.text, this.type, this.oldLineNumber, this.newLineNumber);
  final String text;
  final _DiffType type;
  final int? oldLineNumber;
  final int? newLineNumber;
}
