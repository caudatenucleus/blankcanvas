import 'package:flutter/widgets.dart';
import '../foundation/status.dart';

import '../theme/theme.dart';

/// Status for a Tooltip.
class TooltipStatus extends TooltipControlStatus {}

/// A Tooltip widget that detects hover.
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
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getTooltip(widget.tag);

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final top = offset.dy + size.height + 5;
    final left = offset.dx + (size.width / 2);

    _overlayEntry = OverlayEntry(
      builder: (c) {
        final decoration =
            customization?.decoration(_status) ??
            BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(4),
            );
        final textStyle =
            customization?.textStyle(_status) ??
            const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 12,
              decoration: TextDecoration.none,
            );
        final padding =
            customization?.padding ??
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

        return Positioned(
          top: top,
          left: left,
          child: _TooltipBubble(
            message: widget.message,
            decoration: decoration is BoxDecoration
                ? decoration
                : const BoxDecoration(),
            textStyle: textStyle,
            padding: padding,
            animation: _fadeAnimation,
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
    return MouseRegion(
      onEnter: (_) => _showTooltip(),
      onExit: (_) => _hideTooltip(),
      child: widget.child,
    );
  }
}

class _TooltipBubble extends ImplicitlyAnimatedWidget {
  const _TooltipBubble({
    required this.message,
    required this.decoration,
    required this.textStyle,
    required this.padding,
    required this.animation,
  }) : super(duration: const Duration(milliseconds: 200), curve: Curves.linear);

  final String message;
  final BoxDecoration decoration;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;
  final Animation<double> animation;

  @override
  AnimatedWidgetBaseState<_TooltipBubble> createState() =>
      _TooltipBubbleState();
}

class _TooltipBubbleState extends AnimatedWidgetBaseState<_TooltipBubble> {
  @override
  void initState() {
    super.initState();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animation,
      child: FractionalTranslation(
        translation: const Offset(-0.5, 0),
        child: IgnorePointer(
          child: _TooltipRenderWidget(
            message: widget.message,
            decoration: widget.decoration,
            textStyle: widget.textStyle,
            padding: widget.padding,
          ),
        ),
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    // Basic for now
  }
}

class _TooltipRenderWidget extends LeafRenderObjectWidget {
  const _TooltipRenderWidget({
    required this.message,
    required this.decoration,
    required this.textStyle,
    required this.padding,
  });

  final String message;
  final BoxDecoration decoration;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;

  @override
  RenderTooltipBubble createRenderObject(BuildContext context) {
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
    covariant RenderTooltipBubble renderObject,
  ) {
    renderObject
      ..message = message
      ..decoration = decoration
      ..textStyle = textStyle
      ..padding = padding;
  }
}

class RenderTooltipBubble extends RenderBox {
  RenderTooltipBubble({
    required String message,
    required BoxDecoration decoration,
    required TextStyle textStyle,
    required EdgeInsetsGeometry padding,
  }) : _message = message,
       _decoration = decoration,
       _textStyle = textStyle,
       _padding = padding;

  String _message;
  String get message => _message;
  set message(String value) {
    if (_message == value) return;
    _message = value;
    markNeedsLayout();
  }

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  TextStyle _textStyle;
  TextStyle get textStyle => _textStyle;
  set textStyle(TextStyle value) {
    if (_textStyle == value) return;
    _textStyle = value;
    markNeedsLayout();
  }

  EdgeInsetsGeometry _padding;
  EdgeInsetsGeometry get padding => _padding;
  set padding(EdgeInsetsGeometry value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  TextPainter? _textPainter;

  @override
  void performLayout() {
    _textPainter = TextPainter(
      text: TextSpan(text: message, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final resolvedPadding = padding.resolve(TextDirection.ltr);
    final Size contentSize = _textPainter!.size;

    size = constraints.constrain(
      Size(
        contentSize.width + resolvedPadding.horizontal,
        contentSize.height + resolvedPadding.vertical,
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFF333333);

    // Paint bubble
    if (decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius!.resolve(TextDirection.ltr);
      context.canvas.drawRRect(borderRadius.toRRect(rect), paint);
    } else {
      context.canvas.drawRect(rect, paint);
    }

    // Paint text
    if (_textPainter != null) {
      final resolvedPadding = padding.resolve(TextDirection.ltr);
      _textPainter!.paint(context.canvas, offset + resolvedPadding.topLeft);
    }
  }
}
