import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Tooltip.
class TooltipStatus extends TooltipControlStatus {}

/// A Tooltip widget that detects hover and shows an overlay.
class Tooltip extends SingleChildRenderObjectWidget {
  const Tooltip({
    super.key,
    required this.message,
    required Widget child,
    this.tag,
  }) : super(child: child);

  final String message;
  final String? tag;

  @override
  _TooltipElement createElement() => _TooltipElement(this);

  @override
  RenderTooltip createRenderObject(BuildContext context) {
    return RenderTooltip();
  }
}

class _TooltipElement extends SingleChildRenderObjectElement {
  _TooltipElement(Tooltip super.widget);

  OverlayEntry? _overlayEntry;
  AnimationController? _controller;
  Ticker? _ticker;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (renderObject as RenderTooltip).onHover = _handleHover;
  }

  @override
  void unmount() {
    _removeOverlay();
    _controller?.dispose();
    _ticker?.dispose();
    super.unmount();
  }

  void _handleHover(bool isHovered) {
    if (isHovered) {
      _showTooltip();
    } else {
      _hideTooltip();
    }
  }

  void _showTooltip() {
    if (_overlayEntry != null) return; // Already showing

    final RenderBox renderBox = renderObject as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    // Create entry
    _overlayEntry = OverlayEntry(
      builder: (context) {
        // We need TickerProvider. We can use a TickerProvider implementation wrapper or just manage animation manually in RenderObject.
        // But the Overlay content is a Widget tree?
        // To be lowest-level, we can make Overlay content a RenderObjectWidget too.
        // `_TooltipOverlay`
        return Positioned(
          top: offset.dy + size.height + 5,
          left: offset.dx + size.width / 2,
          child: _TooltipOverlay(
            message: (widget as Tooltip).message,
            tag: (widget as Tooltip).tag,
          ),
        );
      },
    );

    Overlay.of(this).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class RenderTooltip extends RenderProxyBox {
  ValueChanged<bool>? onHover;
  bool _isHovered = false;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent) {
      if (!_isHovered) {
        _isHovered = true;
        onHover?.call(true);
      }
    } else if (event is PointerExitEvent) {
      if (_isHovered) {
        _isHovered = false;
        onHover?.call(false);
      }
    }
    super.handleEvent(event, entry);
  }
}

class _TooltipOverlay extends LeafRenderObjectWidget {
  const _TooltipOverlay({required this.message, this.tag});
  final String message;
  final String? tag;

  @override
  RenderTooltipBubble createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTooltip(
      tag,
    ); // TooltipCustomization
    // We need status to get decoration.
    // But status is local to this overlay?
    // Simplified: Just use default state?
    final decoration =
        customization?.decoration(TooltipStatus()..visible = 1.0) ??
        const BoxDecoration(
          color: Color(0xFF333333),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        );
    final textStyle =
        customization?.textStyle(TooltipStatus()..visible = 1.0) ??
        const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12);
    final padding =
        customization?.padding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

    return RenderTooltipBubble(
      message: message,
      decoration: decoration,
      textStyle: textStyle,
      padding: padding,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTooltipBubble renderObject,
  ) {
    // Update if needed
  }
}

class RenderTooltipBubble extends RenderBox {
  RenderTooltipBubble({
    required String message,
    required Decoration decoration, // Allow Decoration
    required TextStyle textStyle,
    required EdgeInsetsGeometry padding,
  }) : _message = message,
       _decoration = decoration,
       _textStyle = textStyle,
       _padding = padding;

  final String _message;
  final Decoration _decoration;
  final TextStyle _textStyle;
  final EdgeInsetsGeometry _padding;

  // ... setters omitted for brevity, logic assumed similar to before ...

  TextPainter? _textPainter;

  @override
  void performLayout() {
    _textPainter = TextPainter(
      text: TextSpan(text: _message, style: _textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final resolvedPadding = _padding.resolve(TextDirection.ltr);
    final Size contentSize = _textPainter!.size;

    size = constraints.constrain(
      Size(
        contentSize.width + resolvedPadding.horizontal,
        contentSize.height + resolvedPadding.vertical,
      ),
    );

    // Center alignment adjustment logic if needed (handled in Positioned usually)
    // The Positioned in Overlay was left: center of child.
    // So we should translate by -width/2 in paint or use FractionalTranslation in widget tree.
    // Since we are pure RenderObject, can we paint at generic offset?
    // Positioned gives us constraints?
    // Positioned puts us at top/left.
    // We want to center horizontally relative to that left.
    // We can't change our layout position easily from inside (we are inside Stack).
    // We can use transform?
    // Or just let it be aligned left for now (simple).
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Shift to center
    final Offset centeredOffset = offset - Offset(size.width / 2, 0);

    final Rect rect = centeredOffset & size;
    final Paint paint = Paint()..color = const Color(0xFF333333); // Default

    if (_decoration is BoxDecoration) {
      final d = _decoration;
      paint.color = d.color ?? paint.color;
      if (d.borderRadius != null) {
        context.canvas.drawRRect(
          d.borderRadius!.resolve(TextDirection.ltr).toRRect(rect),
          paint,
        );
      } else {
        context.canvas.drawRect(rect, paint);
      }
    }

    final resolvedPadding = _padding.resolve(TextDirection.ltr);
    _textPainter?.paint(
      context.canvas,
      centeredOffset + resolvedPadding.topLeft,
    );
  }
}
