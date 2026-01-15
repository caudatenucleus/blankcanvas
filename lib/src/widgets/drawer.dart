import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Drawer.
class DrawerStatus extends DrawerControlStatus {}

/// A Drawer widget.
class Drawer extends StatelessWidget {
  const Drawer({super.key, required this.child, this.tag});

  final Widget child;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDrawer(tag);

    final status = DrawerStatus(); // Static for now
    final decoration =
        customization?.decoration(status) ??
        const BoxDecoration(color: Color(0xFFFFFFFF));
    final textStyle = customization?.textStyle(status) ?? const TextStyle();
    final double width = customization?.width ?? 300;

    return _DrawerRenderWidget(
      decoration: decoration is BoxDecoration
          ? decoration
          : const BoxDecoration(),
      widthValue: width,
      child: DefaultTextStyle(style: textStyle, child: child),
    );
  }
}

class _DrawerRenderWidget extends SingleChildRenderObjectWidget {
  const _DrawerRenderWidget({
    super.child,
    required this.decoration,
    required this.widthValue,
  });

  final BoxDecoration decoration;
  final double widthValue;

  @override
  RenderDrawerBox createRenderObject(BuildContext context) {
    return RenderDrawerBox(decoration: decoration, widthValue: widthValue);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderDrawerBox renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..widthValue = widthValue;
  }
}

class RenderDrawerBox extends RenderProxyBox {
  RenderDrawerBox({
    required BoxDecoration decoration,
    required double widthValue,
  }) : _decoration = decoration,
       _widthValue = widthValue;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  double _widthValue;
  double get widthValue => _widthValue;
  set widthValue(double value) {
    if (_widthValue == value) return;
    _widthValue = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    if (child != null) {
      child!.layout(
        constraints.tighten(width: widthValue).loosen(),
        parentUsesSize: true,
      );
      size = constraints.constrain(Size(widthValue, constraints.maxHeight));
    } else {
      size = constraints.constrain(Size(widthValue, 0.0));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFFFFFFFF);

    if (decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius!.resolve(TextDirection.ltr);
      context.canvas.drawRRect(borderRadius.toRRect(rect), paint);
      if (decoration.border != null) {
        decoration.border!.paint(
          context.canvas,
          rect,
          borderRadius: borderRadius,
        );
      }
    } else {
      context.canvas.drawRect(rect, paint);
      if (decoration.border != null) {
        decoration.border!.paint(context.canvas, rect);
      }
    }

    if (child != null) {
      context.paintChild(child!, offset);
    }
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
      return Align(
        alignment: Alignment.centerLeft,
        child: builder(buildContext),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? 'Dismiss',
    barrierColor: barrierColor,
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
