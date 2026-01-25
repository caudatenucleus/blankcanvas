import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;

/// A simplified SmartStack that directly creates a RenderStack.
class SmartStack extends MultiChildRenderObjectWidget {
  const SmartStack({
    super.key,
    super.children,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
  });

  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit fit;
  final Clip clipBehavior;

  @override
  RenderStack createRenderObject(BuildContext context) {
    return RenderStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStack renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..fit = fit
      ..clipBehavior = clipBehavior;
  }
}

/// A simplified Positioned wrapper for generic usage if needed, though Stack handles Positioned children natively.
class P extends Positioned {
  const P({
    super.key,
    super.left,
    super.top,
    super.right,
    super.bottom,
    super.width,
    super.height,
    required super.child,
  });

  const P.fill({super.key, required super.child})
    : super(left: 0, top: 0, right: 0, bottom: 0);

  P.center({super.key, required Widget child})
    : super(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        child: layout.Align(alignment: Alignment.center, child: child),
      );
}
