import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// A PDF page placeholder (in a real app, this would render actual PDF content).
class PdfPage {
  const PdfPage({required this.number, this.color});
  final int number;
  final Color? color;
}

/// A PDF viewer widget simulation.
class PdfViewer extends LeafRenderObjectWidget {
  const PdfViewer({super.key, required this.pageCount, this.tag});

  final int pageCount;
  final String? tag;

  @override
  RenderPdfViewer createRenderObject(BuildContext context) {
    return RenderPdfViewer(pageCount: pageCount);
  }

  @override
  void updateRenderObject(BuildContext context, RenderPdfViewer renderObject) {
    renderObject.pageCount = pageCount;
  }
}

class RenderPdfViewer extends RenderBox {
  RenderPdfViewer({required int pageCount}) : _pageCount = pageCount {
    _pan = PanGestureRecognizer()..onUpdate = _handlePanUpdate;
    _scale = ScaleGestureRecognizer()..onUpdate = _handleScaleUpdate;
  }

  int _pageCount;
  set pageCount(int value) {
    _pageCount = value;
    markNeedsLayout();
  }

  late PanGestureRecognizer _pan;
  late ScaleGestureRecognizer _scale;

  double _zoom = 1.0;
  double _scrollY = 0.0;
  double _scrollX = 0.0;

  static const double _pageAspectRatio = 1.414; // A4
  static const double _pageMargin = 20.0;

  @override
  void detach() {
    _pan.dispose();
    _scale.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, constraints.maxHeight.clamp(300, 600)),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    canvas.save();
    canvas.clipRect(offset & size);

    // Background
    canvas.drawRect(offset & size, Paint()..color = const Color(0xFF525659));

    final pageWidth = (size.width - _pageMargin * 2) * _zoom;
    final pageHeight = pageWidth * _pageAspectRatio;
    final totalHeight = _pageCount * (pageHeight + _pageMargin) + _pageMargin;

    // Apply scroll/zoom
    canvas.translate(offset.dx - _scrollX, offset.dy - _scrollY);

    for (int i = 0; i < _pageCount; i++) {
      final y = _pageMargin + i * (pageHeight + _pageMargin);
      final x =
          (size.width * _zoom - pageWidth) / 2 +
          _pageMargin; // Center horizontally

      // Don't paint if out of view
      if (y - _scrollY > size.height + pageHeight ||
          y + pageHeight - _scrollY < 0) {
        continue;
      }

      final pageRect = Rect.fromLTWH(x, y, pageWidth, pageHeight);

      // Shadow
      canvas.drawShadow(
        Path()..addRect(pageRect),
        const Color(0xFF000000),
        4,
        false,
      );

      // Page
      canvas.drawRect(pageRect, Paint()..color = const Color(0xFFFFFFFF));

      // Dummy content simulation
      _paintPageContent(canvas, pageRect, i);
    }

    canvas.restore();

    // Scrollbar
    if (totalHeight > size.height) {
      final barHeight = size.height * (size.height / totalHeight);
      final barTop =
          (_scrollY / (totalHeight - size.height)) * (size.height - barHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            offset.dx + size.width - 8,
            offset.dy + barTop,
            4,
            barHeight,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0x66FFFFFF),
      );
    }

    // Zoom Overlay
    if (_zoom != 1.0) {
      final zoomText = '${(_zoom * 100).toInt()}%';
      textPainter.text = TextSpan(
        text: zoomText,
        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14),
      );
      textPainter.layout();
      final tagRect = Rect.fromLTWH(
        offset.dx + size.width / 2 - 30,
        offset.dy + size.height - 40,
        60,
        24,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(tagRect, const Radius.circular(12)),
        Paint()..color = const Color(0x99000000),
      );
      textPainter.paint(
        canvas,
        tagRect.center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _paintPageContent(Canvas canvas, Rect pageRect, int pageNum) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Page number
    textPainter.text = TextSpan(
      text: 'Page ${pageNum + 1}',
      style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(pageRect.center.dx - textPainter.width / 2, pageRect.bottom - 20),
    );

    // Fake text lines
    final linePaint = Paint()..color = const Color(0xFFE0E0E0);
    double y = pageRect.top + 40;
    while (y < pageRect.bottom - 40) {
      final width = pageRect.width * 0.8 * (0.8 + 0.2 * math.cos(y * 0.1));
      canvas.drawRect(
        Rect.fromLTWH(pageRect.left + 40, y, width, 8),
        linePaint,
      );
      y += 16;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _scrollY -= details.delta.dy;
    _scrollX -= details.delta.dx;
    markNeedsPaint();
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    _zoom = (_zoom * details.scale).clamp(0.5, 3.0);
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _pan.addPointer(event);
    } else if (event is ScaleUpdateDetails) {
      // Logic handled by gesture recognizer callbacks
    }
  }
}
