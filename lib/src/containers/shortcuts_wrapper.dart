import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A wrapper to handle keyboard shortcuts.
/// Maps LogicalKeySet to Actions.
/// Note: Shortcuts/Actions are fundamental Flutter widgets that don't have
/// direct RenderObject equivalents. This wraps them in a RenderObjectWidget.
class ShortcutsWrapper extends SingleChildRenderObjectWidget {
  ShortcutsWrapper({
    super.key,
    required Widget child,
    required this.shortcuts,
    required this.actions,
    this.tag,
  }) : super(
         child: Shortcuts(
           shortcuts: shortcuts,
           child: Actions(actions: actions, child: child),
         ),
       );

  final Map<ShortcutActivator, Intent> shortcuts;
  final Map<Type, Action<Intent>> actions;
  final String? tag;

  @override
  RenderShortcutsWrapper createRenderObject(BuildContext context) {
    return RenderShortcutsWrapper();
  }
}

class RenderShortcutsWrapper extends RenderProxyBox {
  // Pass-through render object - shortcuts are handled by widget layer
}
