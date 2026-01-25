import 'package:flutter/widgets.dart';
import '../rendering/paragraph_primitive.dart';

/// Provides viewport-aware fluid typography scaling.
class FluidTypography {
  const FluidTypography({
    this.baseFontSize = 14.0,
    this.minViewportWidth = 320.0,
    this.maxViewportWidth = 1440.0,
    this.scaleFactor = 1.2,
  });

  final double baseFontSize;
  final double minViewportWidth;
  final double maxViewportWidth;
  final double scaleFactor;

  double calculate(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final t =
        (width - minViewportWidth) / (maxViewportWidth - minViewportWidth);
    final clampedT = t.clamp(0.0, 1.0);
    return baseFontSize * (1.0 + (scaleFactor - 1.0) * clampedT);
  }
}

/// A label that automatically adjusts its text color for contrast using lowest-level RenderObject APIs.
class AutoContrastLabel extends LeafRenderObjectWidget {
  const AutoContrastLabel({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.style,
  });

  final String text;
  final Color backgroundColor;
  final TextStyle? style;

  @override
  RenderObject createRenderObject(BuildContext context) {
    // Calculate luminance
    final luminance = backgroundColor.computeLuminance();
    final textColor = luminance > 0.5
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);

    return RenderParagraphPrimitive(
      text: TextSpan(
        text: text,
        style: (style ?? const TextStyle()).copyWith(color: textColor),
      ),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderParagraphPrimitive renderObject,
  ) {
    final luminance = backgroundColor.computeLuminance();
    final textColor = luminance > 0.5
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);

    renderObject.text = TextSpan(
      text: text,
      style: (style ?? const TextStyle()).copyWith(color: textColor),
    );
  }
}
