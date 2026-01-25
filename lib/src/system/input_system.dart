import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Function signature for actions.
typedef ActionCallback = void Function(BuildContext context, Object? arguments);

/// A registry of named actions available in the application.
class ActionRegistry {
  final Map<String, ActionCallback> _actions = {};

  void register(String id, ActionCallback callback) {
    _actions[id] = callback;
  }

  void unregister(String id) {
    _actions.remove(id);
  }

  void invoke(BuildContext context, String id, {Object? arguments}) {
    final action = _actions[id];
    if (action != null) {
      action(context, arguments);
    } else {
      debugPrint('ActionRegistry: Action "$id" not found.');
    }
  }

  static final ActionRegistry instance = ActionRegistry();
}

/// Manages global keyboard shortcuts using lowest-level RenderObject APIs.
class GlobalShortcutManager extends SingleChildRenderObjectWidget {
  const GlobalShortcutManager({
    super.key,
    required this.shortcuts,
    required super.child,
  });

  final Map<LogicalKeySet, String> shortcuts;

  @override
  RenderGlobalShortcutManager createRenderObject(BuildContext context) {
    return RenderGlobalShortcutManager(shortcuts: shortcuts, context: context);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderGlobalShortcutManager renderObject,
  ) {
    renderObject.shortcuts = shortcuts;
  }
}

class RenderGlobalShortcutManager extends RenderProxyBox {
  RenderGlobalShortcutManager({
    required Map<LogicalKeySet, String> shortcuts,
    required BuildContext context,
  }) : _shortcuts = shortcuts,
       _context = context;

  Map<LogicalKeySet, String> _shortcuts;
  set shortcuts(Map<LogicalKeySet, String> value) {
    if (_shortcuts == value) return;
    _shortcuts = value;
  }

  final BuildContext _context;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void detach() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.detach();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      for (final entry in _shortcuts.entries) {
        if (entry.key.keys.contains(event.logicalKey)) {
          ActionRegistry.instance.invoke(_context, entry.value);
          return true; // Handled
        }
      }
    }
    return false;
  }
}

/// Custom Focus Manager for navigating panel layouts.
class SystemFocusManager {
  static void traverseNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  static void traversePrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }
}
