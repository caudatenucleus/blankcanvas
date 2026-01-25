import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Progress Indicator.
class ProgressStatus extends ProgressControlStatus {}

/// A progress indicator using lowest-level RenderObject APIs.
class ProgressIndicator extends LeafRenderObjectWidget {
  const ProgressIndicator({super.key, this.value, this.tag});

  /// The progress value between 0.0 and 1.0. If null, indeterminate.
  final double? value;
  final String? tag;

  @override
  RenderProgressIndicator createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getProgressIndicator(tag) ??
        ProgressCustomization(
          height: 4.0,
          decoration: (status) => const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          textStyle: (status) => const TextStyle(color: Color(0xFF2196F3)),
        );

    return RenderProgressIndicator(value: value, customization: customization);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderProgressIndicator renderObject,
  ) {
    final customizations = CustomizedTheme.of(context);
    final customization =
        customizations.getProgressIndicator(tag) ??
        ProgressCustomization(
          height: 4.0,
          decoration: (status) => const BoxDecoration(
            color: Color(0xFFEEEEEE),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          textStyle: (status) => const TextStyle(color: Color(0xFF2196F3)),
        );

    renderObject
      ..value = value
      ..customization = customization;
  }
}

class RenderProgressIndicator extends RenderBox implements TickerProvider {
  RenderProgressIndicator({
    double? value,
    required ProgressCustomization customization,
  }) : _value = value,
       _customization = customization;

  double? _value;
  set value(double? v) {
    if (_value == v) return;
    _value = v;
    if (_value == null) {
      _startTicker();
    } else {
      _ticker?.stop();
    }
    markNeedsPaint();
  }

  ProgressCustomization _customization;
  set customization(ProgressCustomization v) {
    if (_customization == v) return;
    _customization = v;
    markNeedsLayout();
    markNeedsPaint();
  }

  // Animation
  Ticker? _ticker;
  double _animationValue = 0.0; // 0.0 to 1.0 for indeterminate cycle

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_value == null) {
      _startTicker();
    }
  }

  @override
  void detach() {
    _ticker?.dispose();
    super.detach();
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  void _startTicker() {
    if (_ticker == null) {
      _ticker = createTicker(_tick)..start();
    } else if (!_ticker!.isActive) {
      _ticker!.start();
    }
  }

  void _tick(Duration elapsed) {
    // 2 second loops
    const double durationMs = 2000.0;
    _animationValue = (elapsed.inMilliseconds % durationMs) / durationMs;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(
      Size(constraints.maxWidth, _customization.height ?? 4.0),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final ProgressStatus status = ProgressStatus()..progress = _value;
    final decoration = _customization.decoration(status);
    final Rect rect = offset & size;

    // Background (Track)
    Paint bgPaint = Paint()..color = const Color(0xFFEEEEEE);
    if (decoration is BoxDecoration && decoration.color != null) {
      bgPaint.color = decoration.color!;
    }

    if (decoration is BoxDecoration && decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius!.resolve(TextDirection.ltr);
      context.canvas.drawRRect(borderRadius.toRRect(rect), bgPaint);
    } else {
      context.canvas.drawRect(rect, bgPaint);
    }

    // Active Indicator Color
    // Usually inferred from textStyle color or a specific decoration field if custom.
    Color activeColor = const Color(0xFF000000);
    // Try getting from customization.textStyle which is standard for foreground color in this system
    final TextStyle ts = _customization.textStyle(status);
    if (ts.color != null) {
      activeColor = ts.color!;
    }

    final Paint activePaint = Paint()..color = activeColor;
    final BorderRadius? activeRadius = (decoration is BoxDecoration)
        ? decoration.borderRadius?.resolve(TextDirection.ltr)
        : null;

    if (_value != null) {
      // Determinate
      final double progressWidth = size.width * _value!.clamp(0.0, 1.0);
      final Rect progressRect = Rect.fromLTWH(
        offset.dx,
        offset.dy,
        progressWidth,
        size.height,
      );

      if (activeRadius != null) {
        // Clipping/rounding complex if we want perfect rounded ends on partial bar.
        // Simple strategy: Round rect for progress
        context.canvas.drawRRect(
          activeRadius.toRRect(progressRect),
          activePaint,
        );
      } else {
        context.canvas.drawRect(progressRect, activePaint);
      }
    } else {
      // Indeterminate
      // Moving segment
      final double segmentWidth = size.width * 0.3;
      final double x =
          (size.width + segmentWidth) * _animationValue - segmentWidth;

      // Clip to track
      context.canvas.save();
      if (activeRadius != null) {
        context.canvas.clipRRect(activeRadius.toRRect(rect));
      } else {
        context.canvas.clipRect(rect);
      }

      final Rect segmentRect = Rect.fromLTWH(
        offset.dx + x,
        offset.dy,
        segmentWidth,
        size.height,
      );
      context.canvas.drawRect(segmentRect, activePaint);

      context.canvas.restore();
    }

    // Border?
    if (decoration is BoxDecoration && decoration.border != null) {
      decoration.border!.paint(
        context.canvas,
        rect,
        borderRadius: (decoration.borderRadius?.resolve(TextDirection.ltr)),
      );
    }
  }
}
