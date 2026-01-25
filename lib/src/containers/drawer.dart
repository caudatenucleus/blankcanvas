import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';
import 'package:blankcanvas/src/layout/layout.dart' as layout;

/// Status for a Drawer.
class DrawerStatus extends DrawerControlStatus {}

/// A Drawer widget.
class Drawer extends SingleChildRenderObjectWidget {
  const Drawer({super.key, required Widget child, this.tag, this.animation})
    : super(child: child);

  final String? tag;
  final Animation<double>? animation;

  @override
  RenderDrawerBox createRenderObject(BuildContext context) {
    return RenderDrawerBox(context: context, tag: tag, animation: animation);
  }

  @override
  void updateRenderObject(BuildContext context, RenderDrawerBox renderObject) {
    renderObject
      ..context = context
      ..tag = tag
      ..animation = animation;
  }
}

class RenderDrawerBox extends RenderProxyBox {
  RenderDrawerBox({
    required BuildContext context,
    String? tag,
    Animation<double>? animation,
  }) : _context = context,
       _tag = tag,
       _animation = animation {
    _animation?.addListener(markNeedsPaint);
  }

  BuildContext _context;
  set context(BuildContext value) {
    _context = value;
  }

  String? _tag;
  set tag(String? value) {
    if (_tag == value) return;
    _tag = value;
    markNeedsPaint();
  }

  Animation<double>? _animation;
  set animation(Animation<double>? value) {
    if (_animation == value) return;
    if (attached && _animation != null) {
      _animation!.removeListener(markNeedsPaint);
    }
    _animation = value;
    if (attached && _animation != null) {
      _animation!.addListener(markNeedsPaint);
    }
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animation?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _animation?.removeListener(markNeedsPaint);
    super.detach();
  }

  // Hardcoded defaults or fetch from customization
  double get _defaultWidth => 300.0;

  @override
  void performLayout() {
    final customizations = CustomizedTheme.of(_context);
    final customization = customizations.getDrawer(_tag);
    final width = customization?.width ?? _defaultWidth;

    if (child != null) {
      child!.layout(
        constraints.tighten(width: width).loosen(),
        parentUsesSize: true,
      );
      size = constraints.constrain(Size(width, constraints.maxHeight));
    } else {
      size = constraints.constrain(Size(width, 0.0));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double animValue = _animation?.value ?? 1.0;

    // Check minimal visibility
    if (animValue == 0) return;

    final double slide = (animValue - 1.0) * size.width;
    final Offset effectiveOffset = offset + Offset(slide, 0);

    final customizations = CustomizedTheme.of(_context);
    final customization = customizations.getDrawer(_tag);
    final status = DrawerStatus();

    final decoration =
        customization?.decoration(status) ??
        const BoxDecoration(color: Color(0xFFFFFFFF));

    // Use BoxPainter
    final BoxPainter painter = decoration.createBoxPainter();
    painter.paint(
      context.canvas,
      effectiveOffset,
      ImageConfiguration(size: size),
    );
    painter.dispose();

    if (child != null) {
      context.paintChild(child!, effectiveOffset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;

    final double animValue = _animation?.value ?? 1.0;
    final double slide = (animValue - 1.0) * size.width;

    // Transform position to child local logic is needed if we strictly follow transform.
    // However, RenderProxyBox defaults pass result through.
    // If we paint shifted, the visual child doesn't match logical child unless logical is also shifted?
    // We didn't shift layout. We shifted paint.
    // So for hit test to match visual, we must "unshift" the position.

    // Hit test happens in parent coordinates (position).
    // Child is at (slide, 0).
    // Local point in child = position - (slide, 0).

    return result.addWithPaintOffset(
      offset: Offset(slide, 0),
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        return child!.hitTest(result, position: transformed);
      },
    );
  }
}

/// Helper to show a drawer using the customization.
Future<T?> showDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? tag,
  bool barrierDismissible = true,
  String? barrierLabel,
}) {
  final customizations = CustomizedTheme.of(context);
  final customization = customizations.getDrawer(tag);
  final barrierColor =
      customization?.modalBarrierColor ?? const Color(0x80000000);

  return showGeneralDialog<T>(
    context: context,
    pageBuilder: (buildContext, animation, secondaryAnimation) {
      return layout.Align(
        alignment: Alignment.centerLeft,
        child: Drawer(
          tag: tag,
          animation: animation,
          child: builder(buildContext),
        ),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? 'Dismiss',
    barrierColor: barrierColor,
    transitionDuration: const Duration(milliseconds: 250),
  );
}
