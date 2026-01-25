import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

/// A spotlight overlay for highlighting elements.
class Spotlight extends SingleChildRenderObjectWidget {
  const Spotlight({
    super.key,
    required Widget child,
    this.isActive = false,
    this.padding = 8.0,
    this.overlayColor = const Color(0x99000000),
    this.onTapOutside,
    this.tag,
  }) : super(child: child);

  final bool isActive;
  final double padding;
  final Color overlayColor;
  final VoidCallback? onTapOutside;
  final String? tag;

  @override
  RenderSpotlight createRenderObject(BuildContext context) {
    return RenderSpotlight(
      isActive: isActive,
      spotlightPadding: padding,
      overlayColor: overlayColor,
      onTapOutside: onTapOutside,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSpotlight renderObject) {
    renderObject
      ..isActive = isActive
      ..spotlightPadding = padding
      ..overlayColor = overlayColor
      ..onTapOutside = onTapOutside;
  }
}

class RenderSpotlight extends RenderProxyBox {
  RenderSpotlight({
    required bool isActive,
    required double spotlightPadding,
    required Color overlayColor,
    VoidCallback? onTapOutside,
  }) : _isActive = isActive,
       _spotlightPadding = spotlightPadding,
       _overlayColor = overlayColor,
       _onTapOutside = onTapOutside {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  bool _isActive;
  set isActive(bool value) {
    if (_isActive != value) {
      _isActive = value;
      markNeedsPaint();
    }
  }

  double _spotlightPadding;
  set spotlightPadding(double value) {
    _spotlightPadding = value;
    markNeedsPaint();
  }

  Color _overlayColor;
  set overlayColor(Color value) {
    _overlayColor = value;
    markNeedsPaint();
  }

  VoidCallback? _onTapOutside;
  set onTapOutside(VoidCallback? value) => _onTapOutside = value;

  late TapGestureRecognizer _tap;
  Rect? _spotlightRect;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    if (!_isActive) return;

    final canvas = context.canvas;
    final childRect = offset & (child?.size ?? Size.zero);
    _spotlightRect = childRect.inflate(_spotlightPadding);

    // Dark overlay with hole
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, 10000, 10000)) // Large rect
      ..addRRect(
        RRect.fromRectAndRadius(_spotlightRect!, const Radius.circular(8)),
      );
    overlayPath.fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, Paint()..color = _overlayColor);

    // Spotlight border
    canvas.drawRRect(
      RRect.fromRectAndRadius(_spotlightRect!, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isActive) return;
    if (_spotlightRect != null &&
        !_spotlightRect!.contains(details.localPosition)) {
      _onTapOutside?.call();
    }
  }

  @override
  bool hitTestSelf(Offset position) => _isActive;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent && _isActive) {
      _tap.addPointer(event);
    }
  }
}
