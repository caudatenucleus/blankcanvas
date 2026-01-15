import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';
import '../theme/customization.dart';

/// Status for a Scrollbar.
class ScrollbarStatus extends ScrollbarControlStatus {}

/// A custom scrollbar that adheres to the BlankCanvas theme.
/// Wraps [RawScrollbar] but allows full customization via [ScrollbarCustomization].
class Scrollbar extends StatefulWidget {
  const Scrollbar({super.key, required this.child, this.controller, this.tag});

  /// The child widget.
  final Widget child;

  /// The [ScrollController] attached to the child's scrollable.
  /// If not provided, one is usually required by [RawScrollbar] unless using PrimaryScrollController logic,
  /// but explicit controller makes it robust.
  final ScrollController? controller;

  final String? tag;

  @override
  State<Scrollbar> createState() => _ScrollbarState();
}

class _ScrollbarState extends State<Scrollbar> with TickerProviderStateMixin {
  final ScrollbarStatus _status = ScrollbarStatus();
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    // RawScrollbar manages fades internally usually, but we want status-based decoration.
    // However, RawScrollbar expects a specific shape or painter.
    // Because 'decoration' in BlankCanvas is a generic Decoration, we can't easily pass it to
    // RawScrollbar.thumbVisibility (boolean) or shape (OutlinedBorder/ShapeBorder).
    // BoxDeocration is NOT a ShapeBorder.
    // So we might have to implement a CustomPainter OR use a Stack+LayoutBuilder approach if we want
    // 100% adherence to 'Decoration' API.
    // BUT... RawScrollbar is nice.
    // Let's try to stick to Hixie's philosophy: "Composed from primitives".
    // A Scrollbar is a track and a thumb.
    // Writing a pure from-scratch scrollbar is hard.
    // Let's use RawScrollbar but we need to trick it or just use it for hit testing?
    // Actually, Flutter 'Scrollbar' paints on an Overlay.
    // If we want a custom 'Decoration' rendered, we likely need to just implement a simpler custom scrollbar
    // OR just support 'color' style customizations if we use RawScrollbar.
    // BUT our 'Theme' returns 'Decoration'.
    // To render a 'Decoration' as a scroll thumb, we need a painter that paints the decoration on the canvas.
    // That is doable: decoration.createBoxPainter().paint(...).
    // So we can subclass ScrollbarPainter? Or just use RawScrollbar with a custom painter?
    // RawScrollbar doesn't easily accept a custom painter.
    // 'RawScrollbar' uses 'ScrollbarPainter'.
    // We can't inject a custom painter easily into RawScrollbar.
    //
    // Plan B: Use a [Stack] and listen to scroll notifications to position a container (Thumb) over the child.
    // This is the "build it yourself" approach which fits BlankCanvas.
    // We only support vertical vertical for now for MVP.
    //
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _hoverController.addListener(
      () => _status.hovered = _hoverController.value,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getScrollbar(widget.tag);

    if (customization == null) {
      // Fallback relative to platform or just basic RawScrollbar
      return RawScrollbar(
        controller: widget.controller,
        thumbColor: const Color(0xFF888888),
        radius: const Radius.circular(5),
        thickness: 8,
        child: widget.child,
      );
    }

    // We will implement a custom scrollbar overlay.
    // This requires a ScrollController. If one isn't passed, we can't easily track offset without Notifications.
    // We will use NotificationListener<ScrollNotification>.

    return _CustomScrollbarBody(
      customization: customization,
      controller: widget.controller,
      status: _status,
      hoverController: _hoverController,
      child: widget.child,
    );
  }
}

class _CustomScrollbarBody extends StatefulWidget {
  const _CustomScrollbarBody({
    required this.child,
    required this.customization,
    this.controller,
    required this.status,
    required this.hoverController,
  });

  final Widget child;
  final ScrollbarCustomization customization;
  final ScrollController? controller;
  final ScrollbarStatus status;
  final AnimationController hoverController;

  @override
  State<_CustomScrollbarBody> createState() => _CustomScrollbarBodyState();
}

class _CustomScrollbarBodyState extends State<_CustomScrollbarBody> {
  double _thumbOffset = 0.0;
  double _thumbSize = 0.0;
  double _trackSize = 0.0;
  bool _isVertical = true;

  void _updateScrollMetrics(ScrollMetrics metrics) {
    setState(() {
      _isVertical = metrics.axis == Axis.vertical;
      _trackSize = _isVertical
          ? metrics.viewportDimension
          : metrics.viewportDimension; // Simplified
      final contentSize = metrics.maxScrollExtent + metrics.viewportDimension;

      if (contentSize <= 0) return;

      final fractionVisible = (metrics.viewportDimension / contentSize).clamp(
        0.0,
        1.0,
      );
      _thumbSize = (_trackSize * fractionVisible).clamp(
        widget.customization.thumbMinLength ?? 20.0,
        _trackSize,
      );

      final scrollFraction = (metrics.pixels / metrics.maxScrollExtent).clamp(
        0.0,
        1.0,
      );
      // Available space for thumb to move is trackSize - thumbSize
      if (metrics.maxScrollExtent > 0) {
        _thumbOffset = scrollFraction * (_trackSize - _thumbSize);
      } else {
        _thumbOffset = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Update thumb position on scroll.
        // Also could update 'visible' status if we wanted fade out.
        if (notification.depth == 0) {
          _updateScrollMetrics(notification.metrics);
        }
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          if (_trackSize > 0 &&
              _thumbSize < _trackSize) // Only show if scrollable
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: widget.customization.thickness ?? 10.0,
              child: MouseRegion(
                onEnter: (_) => widget.hoverController.forward(),
                onExit: (_) => widget.hoverController.reverse(),
                child: ListenableBuilder(
                  listenable: widget.status,
                  builder: (context, _) {
                    final trackDecoration = widget.customization.trackDecoration
                        ?.call(widget.status);
                    final thumbDecoration = widget.customization.decoration(
                      widget.status,
                    );

                    return Container(
                      decoration: trackDecoration,
                      child: Stack(
                        children: [
                          Positioned(
                            top: _thumbOffset,
                            height: _thumbSize,
                            left: 0,
                            right: 0,
                            child: Container(decoration: thumbDecoration),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
