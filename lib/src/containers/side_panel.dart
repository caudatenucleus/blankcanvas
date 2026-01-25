import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// A resizable side panel that can be docked to left or right.
class SidePanel extends SingleChildRenderObjectWidget {
  const SidePanel({
    super.key,
    required Widget child,
    this.width = 250,
    this.minWidth = 100,
    this.maxWidth = 500,
    this.isRightSide = false,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.borderColor = const Color(0xFFEEEEEE),
    this.tag,
  }) : super(child: child);

  final double width;
  final double minWidth;
  final double maxWidth;
  final bool isRightSide;
  final Color backgroundColor;
  final Color borderColor;
  final String? tag;

  @override
  RenderSidePanel createRenderObject(BuildContext context) {
    return RenderSidePanel(
      panelWidth: width,
      minWidth: minWidth,
      maxWidth: maxWidth,
      isRightSide: isRightSide,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderSidePanel renderObject) {
    renderObject
      ..panelWidth = width
      ..minWidth = minWidth
      ..maxWidth = maxWidth
      ..isRightSide = isRightSide
      ..backgroundColor = backgroundColor
      ..borderColor = borderColor;
  }
}

class RenderSidePanel extends RenderProxyBox {
  RenderSidePanel({
    required double panelWidth,
    required double minWidth,
    required double maxWidth,
    required bool isRightSide,
    required Color backgroundColor,
    required Color borderColor,
  }) : _panelWidth = panelWidth,
       _minWidth = minWidth,
       _maxWidth = maxWidth,
       _isRightSide = isRightSide,
       _backgroundColor = backgroundColor,
       _borderColor = borderColor;

  double _panelWidth;
  set panelWidth(double value) {
    if (_panelWidth != value) {
      _panelWidth = value;
      markNeedsLayout();
    }
  }

  double _minWidth;
  set minWidth(double value) {
    _minWidth = value;
  }

  double _maxWidth;
  set maxWidth(double value) {
    _maxWidth = value;
  }

  bool _isRightSide;
  set isRightSide(bool value) {
    if (_isRightSide != value) {
      _isRightSide = value;
      markNeedsPaint();
    }
  }

  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  Color _borderColor;
  set borderColor(Color value) {
    if (_borderColor != value) {
      _borderColor = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    final childConstraints = BoxConstraints(
      minWidth: _panelWidth.clamp(_minWidth, _maxWidth),
      maxWidth: _panelWidth.clamp(_minWidth, _maxWidth),
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
    );
    child?.layout(childConstraints, parentUsesSize: true);
    size = constraints.constrain(
      Size(_panelWidth.clamp(_minWidth, _maxWidth), constraints.maxHeight),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final rect = offset & size;

    // Background
    canvas.drawRect(rect, Paint()..color = _backgroundColor);

    // Border
    final borderPaint = Paint()
      ..color = _borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (_isRightSide) {
      canvas.drawLine(rect.topLeft, rect.bottomLeft, borderPaint);
    } else {
      canvas.drawLine(rect.topRight, rect.bottomRight, borderPaint);
    }

    // Paint child
    super.paint(context, offset);
  }
}
