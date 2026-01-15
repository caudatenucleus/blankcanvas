import 'package:flutter/widgets.dart';

import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Progress Indicator.
class ProgressStatus extends ProgressControlStatus {}

class ProgressIndicator extends StatefulWidget {
  const ProgressIndicator({super.key, this.value, this.tag});

  /// The progress value between 0.0 and 1.0. If null, indeterminate.
  final double? value;
  final String? tag;

  @override
  State<ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with TickerProviderStateMixin {
  final ProgressStatus _status = ProgressStatus();

  late final AnimationController _indeterminateController;

  @override
  void initState() {
    super.initState();
    _indeterminateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.value == null) {
      _indeterminateController.repeat();
    }

    _status.progress = widget.value;
  }

  @override
  void didUpdateWidget(ProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _status.progress = widget.value;

    if (widget.value == null && !_indeterminateController.isAnimating) {
      _indeterminateController.repeat();
    } else if (widget.value != null && _indeterminateController.isAnimating) {
      _indeterminateController.stop();
    }
  }

  @override
  void dispose() {
    _indeterminateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getProgressIndicator(widget.tag);

    if (customization == null) {
      return SizedBox(
        height: 4,
        child: ColoredBox(
          color: const Color(0xFFEEEEEE),
          child: FractionallySizedBox(
            widthFactor: widget.value ?? 0.3,
            child: const ColoredBox(color: Color(0xFF000000)),
          ),
        ),
      );
    }

    final decoration = customization.decoration(_status);
    final double height = customization.height ?? 4.0;

    return AnimatedBuilder(
      animation: _indeterminateController,
      builder: (context, child) {
        return _ProgressRenderWidget(
          decoration: decoration is BoxDecoration
              ? decoration
              : const BoxDecoration(),
          height: height,
          progress: widget.value,
          animationValue: _indeterminateController.value,
        );
      },
    );
  }
}

class _ProgressRenderWidget extends LeafRenderObjectWidget {
  const _ProgressRenderWidget({
    required this.decoration,
    required this.height,
    this.progress,
    required this.animationValue,
  });

  final BoxDecoration decoration;
  final double height;
  final double? progress;
  final double animationValue;

  @override
  RenderProgressIndicator createRenderObject(BuildContext context) {
    return RenderProgressIndicator(
      decoration: decoration,
      heightValue: height,
      progress: progress,
      animationValue: animationValue,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderProgressIndicator renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..heightValue = height
      ..progress = progress
      ..animationValue = animationValue;
  }
}

class RenderProgressIndicator extends RenderBox {
  RenderProgressIndicator({
    required BoxDecoration decoration,
    required double heightValue,
    double? progress,
    required double animationValue,
  }) : _decoration = decoration,
       _heightValue = heightValue,
       _progress = progress,
       _animationValue = animationValue;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  double _heightValue;
  double get heightValue => _heightValue;
  set heightValue(double value) {
    if (_heightValue == value) return;
    _heightValue = value;
    markNeedsLayout();
  }

  double? _progress;
  double? get progress => _progress;
  set progress(double? value) {
    if (_progress == value) return;
    _progress = value;
    markNeedsPaint();
  }

  double _animationValue;
  double get animationValue => _animationValue;
  set animationValue(double value) {
    if (_animationValue == value) return;
    _animationValue = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, heightValue));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFFEEEEEE);

    // Paint background (track)
    if (decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius!.resolve(TextDirection.ltr);
      context.canvas.drawRRect(borderRadius.toRRect(rect), paint);
    } else {
      context.canvas.drawRect(rect, paint);
    }

    // Paint progress
    if (progress != null) {
      final double progressWidth = size.width * progress!.clamp(0.0, 1.0);
      final Rect progressRect = offset & Size(progressWidth, size.height);
      final Paint progressPaint = Paint()
        ..color = const Color(0xFF000000); // Default to black for indicator

      if (decoration.borderRadius != null) {
        final borderRadius = decoration.borderRadius!.resolve(
          TextDirection.ltr,
        );
        context.canvas.drawRRect(
          borderRadius.toRRect(progressRect),
          progressPaint,
        );
      } else {
        context.canvas.drawRect(progressRect, progressPaint);
      }
    } else {
      // Indeterminate: paint a moving segment
      final double segmentWidth = size.width * 0.3;
      final double x =
          (size.width + segmentWidth) * animationValue - segmentWidth;
      final Rect progressRect = Rect.fromLTWH(
        offset.dx + x,
        offset.dy,
        segmentWidth,
        size.height,
      ).intersect(rect);

      final Paint progressPaint = Paint()
        ..color = const Color(0xFF000000).withValues(alpha: 0.5);

      context.canvas.drawRect(progressRect, progressPaint);
    }
  }
}
