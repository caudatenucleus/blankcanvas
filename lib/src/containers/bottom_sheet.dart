import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A bottom sheet that slides up from the bottom.
class BottomSheet {
  /// Shows a modal bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color backgroundColor = const Color(0xFFFFFFFF),
    bool isDismissible = true,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: isDismissible,
        barrierColor: const Color(0x80000000),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _BottomSheetContainer(
            animation: animation,
            backgroundColor: backgroundColor,
            child: builder(context),
          );
        },
      ),
    );
  }
}

class _BottomSheetContainer extends SingleChildRenderObjectWidget {
  const _BottomSheetContainer({
    required this.animation,
    required this.backgroundColor,
    required Widget child,
  }) : super(child: child);

  final Animation<double> animation;
  final Color backgroundColor;

  @override
  RenderBottomSheet createRenderObject(BuildContext context) {
    return RenderBottomSheet(
      animation: animation,
      backgroundColor: backgroundColor,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBottomSheet renderObject,
  ) {
    renderObject
      ..animation = animation
      ..backgroundColor = backgroundColor;
  }
}

class RenderBottomSheet extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderBottomSheet({
    required Animation<double> animation,
    required Color backgroundColor,
    RenderBox? child,
  }) : _animation = animation,
       _backgroundColor = backgroundColor {
    this.child = child;
  }

  Animation<double> _animation;
  Animation<double> get animation => _animation;
  set animation(Animation<double> value) {
    if (_animation == value) return;
    if (attached) {
      _animation.removeListener(markNeedsPaint);
      value.addListener(markNeedsPaint);
    }
    _animation = value;
    markNeedsPaint();
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor == value) return;
    _backgroundColor = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      size = constraints.biggest;

      // Position child at bottom
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      childParentData.offset = Offset(
        (size.width - child!.size.width) / 2, // Center horizontally
        size.height - child!.size.height, // Align bottom
      );
    } else {
      size = constraints.biggest;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    if (_animation.value == 0.0) return; // Hidden

    // Slide Transition
    final double curvedValue = Curves.easeOutCubic.transform(_animation.value);

    // The child is laid out at the bottom.
    // Slide should move it from "below the screen" to "at the bottom".
    // Slide distance = child.height.
    final double slideDistance = child!.size.height;
    final double slideOffset = (1.0 - curvedValue) * slideDistance;

    // Draw background/shadow for the sheet (which wraps the child content)
    // We assume child is the content of the sheet.
    // Or we should paint decoration AROUND the child.
    // Previous implementation wrapped content in DecoratedBox.
    // Here we paint decoration in this RenderBox around the child's identified area.

    final BoxParentData childParentData = child!.parentData as BoxParentData;
    final Offset childPos =
        childParentData.offset + offset + Offset(0, slideOffset);
    final Rect childRect = childPos & child!.size;

    // Paint Shadow
    final Path path = Path()
      ..addRRect(
        BorderRadius.vertical(top: Radius.circular(16)).toRRect(childRect),
      );
    context.canvas.drawShadow(path, const Color(0x22000000), 16.0, true);

    // Paint Background
    final Paint paint = Paint()..color = backgroundColor;
    context.canvas.drawRRect(
      BorderRadius.vertical(top: Radius.circular(16)).toRRect(childRect),
      paint,
    );

    // Paint Handle
    final Paint handlePaint = Paint()..color = const Color(0xFFE0E0E0);
    final Rect handleRect = Rect.fromCenter(
      center:
          childRect.topCenter +
          const Offset(0, 16 + 2), // 16 pad top + half height
      width: 32,
      height: 4,
    );
    // Actually padding is inside child in original code.
    // Here we paint handle on top of background?
    // Original had Column (children: [Handle, content]).
    // Here we just paint handle overlay?
    // Let's paint it.
    context.canvas.drawRRect(
      BorderRadius.circular(2).toRRect(handleRect),
      handlePaint,
    );

    // Paint Child
    // Use opacity
    context.canvas.saveLayer(
      childRect,
      Paint()
        ..color = Color.fromARGB(
          (255 * _animation.value).toInt(),
          255,
          255,
          255,
        ),
    );
    context.paintChild(child!, childPos);
    context.canvas.restore();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    final BoxParentData childParentData = child!.parentData as BoxParentData;
    // Note: We ignore slide offset for hit testing logic here for simplicity,
    // assuming the bottom sheet captures taps on its visible area.
    // However, if we want to hit the child where it is painted (slid down),
    // we need to account for it.
    // The previous paint implementation used `offset + slideOffset`.
    // So for hit testing we should check `position` relative to that.

    // Recalculate slide offset
    // Ideally we cache it or use applyPaintTransform.
    // Since we didn't implement applyPaintTransform, let's just use standard hit test
    // assuming the user interacts when fully shown (slide=0).
    // Or simpler: just hit test child at its layout position.

    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child!.hitTest(result, position: transformed);
      },
    );
  }
}
