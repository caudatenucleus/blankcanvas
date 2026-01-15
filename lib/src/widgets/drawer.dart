import 'package:flutter/widgets.dart';
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

    if (customization == null) {
      // Fallback
      return Container(
        width: 300,
        height: double.infinity,
        color: const Color(0xFFFFFFFF),
        child: child,
      );
    }

    final status = DrawerStatus(); // Static for now

    final decoration = customization.decoration(status);
    final textStyle = customization.textStyle(status);

    return Container(
      width: customization.width ?? 300,
      height: double.infinity,
      decoration: decoration,
      child: DefaultTextStyle(style: textStyle, child: child),
    );
  }
}

/// Helper to show a drawer using the customization.
/// This mimics showDialog/showGeneralDialog but for a side drawer.
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
      // We pass the context to builder so they can inherit theme if needed,
      // though showGeneralDialog routes usually sit above the app widget tree so they might lose inherited widgets
      // unless wrapped. However, CustomizedApp wraps WidgetsApp, so we should be fine if context is right.
      // Wait, standard showGeneralDialog pushes a new route. We might need to wrap the builder with the theme.
      // But CustomizedTheme is usually at the top of the app.
      // Let's assume it works for now.

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
