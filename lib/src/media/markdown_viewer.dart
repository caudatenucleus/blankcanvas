import 'package:flutter/widgets.dart';

/// A simple markdown viewer widget.
class MarkdownViewer extends LeafRenderObjectWidget {
  const MarkdownViewer({super.key, required this.markdown, this.tag});

  final String markdown;
  final String? tag;

  @override
  RenderMarkdownViewer createRenderObject(BuildContext context) {
    return RenderMarkdownViewer(markdown: markdown);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMarkdownViewer renderObject,
  ) {
    renderObject.markdown = markdown;
  }
}

class RenderMarkdownViewer extends RenderBox {
  RenderMarkdownViewer({required String markdown}) : _markdown = markdown {
    _parseMarkdown();
  }

  String _markdown;
  set markdown(String value) {
    _markdown = value;
    _parseMarkdown();
  }

  final List<_MarkdownBlock> _blocks = [];

  void _parseMarkdown() {
    _blocks.clear();
    final lines = _markdown.split('\n');

    for (final line in lines) {
      if (line.startsWith('# ')) {
        _blocks.add(_MarkdownBlock(line.substring(2), _BlockType.h1));
      } else if (line.startsWith('## ')) {
        _blocks.add(_MarkdownBlock(line.substring(3), _BlockType.h2));
      } else if (line.startsWith('### ')) {
        _blocks.add(_MarkdownBlock(line.substring(4), _BlockType.h3));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        _blocks.add(_MarkdownBlock(line.substring(2), _BlockType.bullet));
      } else if (line.startsWith('```')) {
        _blocks.add(_MarkdownBlock(line.substring(3), _BlockType.code));
      } else if (line.startsWith('> ')) {
        _blocks.add(_MarkdownBlock(line.substring(2), _BlockType.quote));
      } else if (line.trim().isEmpty) {
        _blocks.add(_MarkdownBlock('', _BlockType.empty));
      } else {
        _blocks.add(_MarkdownBlock(line, _BlockType.paragraph));
      }
    }

    markNeedsLayout();
  }

  @override
  void performLayout() {
    double height = 20;
    for (final block in _blocks) {
      switch (block.type) {
        case _BlockType.h1:
          height += 36;
          break;
        case _BlockType.h2:
          height += 28;
          break;
        case _BlockType.h3:
          height += 24;
          break;
        case _BlockType.empty:
          height += 12;
          break;
        default:
          height += 22;
      }
    }
    size = constraints.constrain(
      Size(constraints.maxWidth, height.clamp(100, 500)),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double y = offset.dy + 10;

    for (final block in _blocks) {
      if (y > offset.dy + size.height) break;

      double lineHeight;
      TextStyle style;
      double indent = 0;

      switch (block.type) {
        case _BlockType.h1:
          style = const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          );
          lineHeight = 36;
          break;
        case _BlockType.h2:
          style = const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          );
          lineHeight = 28;
          break;
        case _BlockType.h3:
          style = const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          );
          lineHeight = 24;
          break;
        case _BlockType.bullet:
          style = const TextStyle(fontSize: 14, color: Color(0xFF333333));
          lineHeight = 22;
          indent = 20;
          // Draw bullet
          canvas.drawCircle(
            Offset(offset.dx + 10, y + 10),
            3,
            Paint()..color = const Color(0xFF333333),
          );
          break;
        case _BlockType.code:
          style = const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            color: Color(0xFF666666),
          );
          lineHeight = 22;
          canvas.drawRect(
            Rect.fromLTWH(offset.dx, y, size.width, lineHeight),
            Paint()..color = const Color(0xFFF5F5F5),
          );
          indent = 8;
          break;
        case _BlockType.quote:
          style = const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Color(0xFF666666),
          );
          lineHeight = 22;
          canvas.drawRect(
            Rect.fromLTWH(offset.dx, y, 3, lineHeight),
            Paint()..color = const Color(0xFFBDBDBD),
          );
          indent = 12;
          break;
        case _BlockType.empty:
          y += 12;
          continue;
        default:
          style = const TextStyle(fontSize: 14, color: Color(0xFF333333));
          lineHeight = 22;
      }

      textPainter.text = TextSpan(text: block.text, style: style);
      textPainter.layout(maxWidth: size.width - indent - 8);
      textPainter.paint(canvas, Offset(offset.dx + indent, y));

      y += lineHeight;
    }
  }
}

enum _BlockType { h1, h2, h3, paragraph, bullet, code, quote, empty }

class _MarkdownBlock {
  _MarkdownBlock(this.text, this.type);
  final String text;
  final _BlockType type;
}
