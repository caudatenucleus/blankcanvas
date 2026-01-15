import 'package:flutter/material.dart';

import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Tooltip.
class TooltipStatus extends TooltipControlStatus {}

/// A Tooltip widget that detects hover/long press.
/// This is a simplified implementation using Overlay.
class Tooltip extends StatefulWidget {
  const Tooltip({
    super.key,
    required this.message,
    required this.child,
    this.tag,
  });

  final String message;
  final Widget child;
  final String? tag;

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> with SingleTickerProviderStateMixin {
  final TooltipStatus _status = TooltipStatus();
  OverlayEntry? _overlayEntry;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  // Timer for waitDuration? Simplified for now: instant show or fixed 500ms
  // In a full impl, we'd use customization.waitDuration

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && _overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  void dispose() {
    _status.dispose();
    _controller.dispose();
    _overlayEntry?.remove(); // Ensure removed if disposing while showing
    super.dispose();
  }

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTooltip(widget.tag);

    // Create Overlay Entry
    _overlayEntry = OverlayEntry(
      builder: (context) {
        Widget content = Text(
          widget.message,
          style:
              customization?.textStyle(_status) ??
              const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12),
        );

        BoxDecoration decoration =
            (customization?.decoration(_status) as BoxDecoration?) ??
            BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(4),
            );

        return Positioned(
          // Simplified positioning. Ideal implementation calculates offset from RenderBox.
          // We'll use a CompositedTransformFollower if we had a Link.
          // For complexity reduction, we'll try to just center it or put it near mouse if possible,
          // but without mouse event details here it's hard.
          // Let's use a CustomSingleChildLayout or just follow the widget's position.
          // BETTER: Just use the Portal or similar, but we are dependent-less.

          // Let's defer actual sophisticated positioning.
          // We will wrap the child in a CompositedTransformTarget.
          top: 100, // Dummy
          left: 100, // Dummy
          child: Material(
            // We need Material/DefaultTextStyle to be safe on Overlay
            color: Colors.transparent, // Fix: Overlay is transparent usually
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: decoration,
                padding:
                    customization?.padding ??
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: content,
              ),
            ),
          ),
        );
      },
    );

    // BUT we need the position.
    // Let's just create a simpler overlaid widget structure via custom render object or user Just use standard Tooltip logic?
    // We are building *custom* controls.

    // For now, let's just make the child toggle a state that shows a widget *locally* if possible, or use Overlay with calculated position.

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    // Calculate tooltip position (e.g. below)
    final top = offset.dy + size.height + 5;
    final left =
        offset.dx +
        (size.width /
            2); // Centered roughly (text won't be centered unless measured)

    _overlayEntry = OverlayEntry(
      builder: (c) {
        return Positioned(
          top: top,
          left: left,
          // To center the tooltip itself, we'd need its size.
          // We can use FractionalTranslation.
          child: FractionalTranslation(
            translation: const Offset(-0.5, 0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: IgnorePointer(
                // Tooltips shouldn't block hits usually
                child: Container(
                  decoration:
                      (customization?.decoration(_status) as BoxDecoration?) ??
                      BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(4),
                      ),
                  padding:
                      customization?.padding ??
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: DefaultTextStyle(
                    style:
                        customization?.textStyle(_status) ??
                        const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 12,
                          decoration: TextDecoration.none,
                        ),
                    child: Text(widget.message),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _status.visible = 1.0;
    _controller.forward();
  }

  void _hideTooltip() {
    _status.visible = 0.0;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Only used to lookup defaults, real usage in _show
    // final customizations = CustomizedTheme.of(context);

    return MouseRegion(
      onEnter: (_) => _showTooltip(),
      onExit: (_) => _hideTooltip(),
      child: widget.child,
    );
  }
}
