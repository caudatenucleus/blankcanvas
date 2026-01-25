import 'package:flutter/widgets.dart'
    hide
        FadeTransition,
        ScaleTransition,
        SlideTransition,
        RotationTransition,
        SizeTransition;
import 'transitions.dart' as transitions;

enum PageTransitionType {
  fade,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  scale,
  size,
  rotate,
}

/// A simplified [PageRouteBuilder] for common transitions using blankcanvas primitives.
class PageTransition<T> extends PageRouteBuilder<T> {
  PageTransition({
    required this.child,
    required this.type,
    this.alignment = Alignment.center,
    this.ease = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
    Duration reverseDuration = const Duration(milliseconds: 300),
    bool opaque = false,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: reverseDuration,
         opaque: opaque,
         barrierDismissible: barrierDismissible,
         barrierColor: barrierColor,
         barrierLabel: barrierLabel,
         maintainState: maintainState,
         fullscreenDialog: fullscreenDialog,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: ease,
           );
           switch (type) {
             case PageTransitionType.fade:
               return transitions.OpacityTransition(
                 opacity: curvedAnimation,
                 child: child,
               );
             case PageTransitionType.rightToLeft:
               return transitions.SlidingTransition(
                 position: Tween<Offset>(
                   begin: const Offset(1, 0),
                   end: Offset.zero,
                 ).animate(curvedAnimation),
                 child: child,
               );
             case PageTransitionType.leftToRight:
               return transitions.SlidingTransition(
                 position: Tween<Offset>(
                   begin: const Offset(-1, 0),
                   end: Offset.zero,
                 ).animate(curvedAnimation),
                 child: child,
               );
             case PageTransitionType.upToDown:
               return transitions.SlidingTransition(
                 position: Tween<Offset>(
                   begin: const Offset(0, -1),
                   end: Offset.zero,
                 ).animate(curvedAnimation),
                 child: child,
               );
             case PageTransitionType.downToUp:
               return transitions.SlidingTransition(
                 position: Tween<Offset>(
                   begin: const Offset(0, 1),
                   end: Offset.zero,
                 ).animate(curvedAnimation),
                 child: child,
               );
             case PageTransitionType.scale:
               return transitions.ScaleTransition(
                 scale: curvedAnimation,
                 alignment: alignment,
                 child: child,
               );
             case PageTransitionType.size:
               return transitions.SizeTransition(
                 sizeFactor: curvedAnimation,
                 child: child,
               );
             case PageTransitionType.rotate:
               return transitions.RotationTransition(
                 turns: curvedAnimation,
                 alignment: alignment,
                 child: child,
               );
           }
         },
       );

  final Widget child;
  final PageTransitionType type;
  final Alignment alignment;
  final Curve ease;
}
