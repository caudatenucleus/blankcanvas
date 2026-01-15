import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Menu Item.
class MenuItemStatus extends MenuItemControlStatus {}

/// A Menu Item widget.
class MenuItem extends StatefulWidget {
  const MenuItem({
    super.key,
    required this.child,
    required this.onPressed,
    this.tag,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final String? tag;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem>
    with SingleTickerProviderStateMixin {
  final MenuItemStatus _status = MenuItemStatus();
  late final AnimationController _hoverController;
  late final AnimationController _focusController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _hoverController.addListener(
      () => _status.hovered = _hoverController.value,
    );
    _focusController.addListener(
      () => _status.focused = _focusController.value,
    );

    _focusNode.addListener(() {
      _focusNode.hasFocus
          ? _focusController.forward()
          : _focusController.reverse();
    });

    _status.enabled = widget.onPressed != null ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getMenuItem(widget.tag);

    if (customization == null) {
      // Fallback
      return GestureDetector(
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: DefaultTextStyle(
            style: const TextStyle(color: Color(0xFF000000)),
            child: widget.child,
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _status,
      builder: (context, _) {
        final decoration = customization.decoration(_status);
        final textStyle = customization.textStyle(_status);

        return MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          cursor: widget.onPressed != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Focus(
              focusNode: _focusNode,
              child: Container(
                decoration: decoration,
                padding:
                    customization.padding ??
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: DefaultTextStyle(style: textStyle, child: widget.child),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A vertical Menu container.
/// Usually wrapped in a popup, but can be inline.
class Menu extends StatelessWidget {
  const Menu({super.key, required this.children, this.tag});

  final List<Widget> children;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getMenu(tag);

    if (customization == null) {
      // Fallback
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    // We create a dummy status for the Menu container (it's mostly static, but could support hover/focus if focusable)
    // CardControlStatus is re-used for MenuCustomization.
    final status = CardControlStatus(); // Static for now

    final decoration = customization.decoration(status);
    final textStyle = customization.textStyle(status);

    return Container(
      decoration: decoration,
      child: DefaultTextStyle(
        // Default text style for menu items if they don't override
        style: textStyle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

// TODO: Helper for popup menus (overlay)
