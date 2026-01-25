import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// One step in a tour.
class TourStep {
  const TourStep({
    required this.target,
    required this.title,
    required this.description,
  });

  final GlobalKey target;
  final String title;
  final String description;
}

/// A guided tour widget.
/// Note: Tours with overlays typically require widget-layer support.
/// This implementation paints tour overlay directly in RenderObject.
class Tour extends SingleChildRenderObjectWidget {
  const Tour({
    super.key,
    required this.steps,
    required Widget child,
    this.onComplete,
    this.tag,
  }) : super(child: child);

  final List<TourStep> steps;
  final VoidCallback? onComplete;
  final String? tag;

  @override
  RenderTour createRenderObject(BuildContext context) {
    return RenderTour(steps: steps, onComplete: onComplete);
  }

  @override
  void updateRenderObject(BuildContext context, RenderTour renderObject) {
    renderObject
      ..steps = steps
      ..onComplete = onComplete;
  }
}

class RenderTour extends RenderProxyBox {
  RenderTour({required List<TourStep> steps, VoidCallback? onComplete})
    : _steps = steps,
      _onComplete = onComplete {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<TourStep> _steps;
  set steps(List<TourStep> value) {
    _steps = value;
    markNeedsPaint();
  }

  VoidCallback? _onComplete;
  set onComplete(VoidCallback? value) => _onComplete = value;

  late TapGestureRecognizer _tap;
  int _currentStep = -1;

  void start() {
    _currentStep = 0;
    markNeedsPaint();
  }

  void next() {
    if (_currentStep < _steps.length - 1) {
      _currentStep++;
      markNeedsPaint();
    } else {
      stop();
      _onComplete?.call();
    }
  }

  void stop() {
    _currentStep = -1;
    markNeedsPaint();
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  Rect? _nextButtonRect;
  Rect? _skipButtonRect;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    if (_currentStep < 0 || _currentStep >= _steps.length) return;

    final canvas = context.canvas;
    final step = _steps[_currentStep];
    final renderBox =
        step.target.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final targetSize = renderBox.size;
    final targetPos = renderBox.localToGlobal(Offset.zero);

    // Darken overlay
    canvas.drawRect(offset & size, Paint()..color = const Color(0x80000000));

    // Highlight hole
    final holeRect = Rect.fromLTWH(
      targetPos.dx - 4,
      targetPos.dy - 4,
      targetSize.width + 8,
      targetSize.height + 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(holeRect, const Radius.circular(4)),
      Paint()..blendMode = BlendMode.clear,
    );

    // Tooltip below target
    final tooltipRect = Rect.fromLTWH(
      targetPos.dx,
      targetPos.dy + targetSize.height + 12,
      200,
      120,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tooltipRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFFFFFFF),
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Title
    textPainter.text = TextSpan(
      text: step.title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Color(0xFF333333),
      ),
    );
    textPainter.layout(maxWidth: 180);
    textPainter.paint(
      canvas,
      Offset(tooltipRect.left + 16, tooltipRect.top + 16),
    );

    // Description
    textPainter.text = TextSpan(
      text: step.description,
      style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
    );
    textPainter.layout(maxWidth: 180);
    textPainter.paint(
      canvas,
      Offset(tooltipRect.left + 16, tooltipRect.top + 40),
    );

    // Buttons
    _skipButtonRect = Rect.fromLTWH(
      tooltipRect.left + 16,
      tooltipRect.bottom - 32,
      40,
      20,
    );
    _nextButtonRect = Rect.fromLTWH(
      tooltipRect.right - 70,
      tooltipRect.bottom - 36,
      60,
      28,
    );

    // Skip text
    textPainter.text = const TextSpan(
      text: 'Skip',
      style: TextStyle(
        color: Color(0xFF999999),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, _skipButtonRect!.topLeft);

    // Next button
    canvas.drawRRect(
      RRect.fromRectAndRadius(_nextButtonRect!, const Radius.circular(4)),
      Paint()..color = const Color(0xFF2196F3),
    );
    textPainter.text = TextSpan(
      text: _currentStep == _steps.length - 1 ? 'Finish' : 'Next',
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        _nextButtonRect!.center.dx - textPainter.width / 2,
        _nextButtonRect!.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    if (_currentStep < 0) return;

    final local = details.localPosition;
    if (_nextButtonRect?.contains(local) == true) {
      next();
    } else if (_skipButtonRect?.contains(local) == true) {
      stop();
    }
  }

  @override
  bool hitTestSelf(Offset position) => _currentStep >= 0;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent && _currentStep >= 0) {
      _tap.addPointer(event);
    }
  }
}
