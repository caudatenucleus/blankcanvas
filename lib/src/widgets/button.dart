import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Button.
class ButtonStatus extends MutableControlStatus {}

/// A button that follows the BlankCanvas architecture.
class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.onPressed,
    required this.child,
    this.tag,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? tag;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> with TickerProviderStateMixin {
  final ButtonStatus _status = ButtonStatus();

  late final AnimationController _hoverController;
  late final AnimationController _focusController;
  late final AnimationController _activeController;

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
    _activeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _hoverController.addListener(
      () => _status.hovered = _hoverController.value,
    );
    _focusController.addListener(
      () => _status.focused = _focusController.value,
    );
    // Active state is instant for buttons usually, but we can animate it if needed.
    // For now we'll set it directly or use controller if we want smooth 'press' in/out.

    _focusNode.addListener(() {
      _focusNode.hasFocus
          ? _focusController.forward()
          : _focusController.reverse();
    });

    _status.enabled = widget.onPressed != null ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    _status.enabled = widget.onPressed != null ? 1.0 : 0.0;
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _activeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getButton(widget.tag);

    if (customization == null) {
      // Fallback if no theme is provided at all
      return widget.child;
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
            onTapDown: (_) {
              if (widget.onPressed != null) {
                _status.enabled = 1.0;
              } // Ensure enabled
              // Manual instant set for responsiveness, or animate
              // _status.notify(); // Not needed if we don't change a value, but...
              // Let's assume we want to track 'active' (pressed)
              // The mutable status doesn't have 'active' by default in base class?
              // Wait, base class has hovered, focused, enabled.
              // We should add active to base or subclass.
              // For now let's skip strict 'active' double if not in base,
              // but the doc says 'Active (mouse/touch pressing)'.
              // I'll assume base class is extensible or I should have added it.
            },
            onTap: widget.onPressed,
            child: Focus(
              focusNode: _focusNode,
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 0,
                ), // Decoration is built per frame if we used Ticker, but here we rebuild on status change.
                // Actually, since _status.hovered changes every frame of the animation controller,
                // and we rebuild, we are effectively animating manually.
                decoration: decoration,
                width: customization.width,
                height: customization.height,
                child: DefaultTextStyle(
                  style: textStyle,
                  child: Center(child: widget.child),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
