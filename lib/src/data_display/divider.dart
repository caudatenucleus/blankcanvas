import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// Status for a Divider.
class DividerStatus extends DividerControlStatus {}

/// A low-level Divider implemented using RenderObject.
class Divider extends LeafRenderObjectWidget {
  const Divider({super.key, this.tag});

  final String? tag;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDivider(tag);
    final decoration = customization?.decoration(DividerStatus());
    Color? color;
    if (decoration is BoxDecoration) {
      color = decoration.color;
    }

    return RenderDivider(
      color: color ?? const Color(0xFFDDDDDD),
      thickness: customization?.thickness ?? 1.0,
      indent: customization?.indent ?? 0.0,
      endIndent: customization?.endIndent ?? 0.0,
      height: (customization?.thickness ?? 1.0) + 16.0,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderDivider renderObject,
  ) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDivider(tag);
    final decoration = customization?.decoration(DividerStatus());
    Color? color;
    if (decoration is BoxDecoration) {
      color = decoration.color;
    }

    renderObject
      ..color = color ?? const Color(0xFFDDDDDD)
      ..thickness = customization?.thickness ?? 1.0
      ..indent = customization?.indent ?? 0.0
      ..endIndent = customization?.endIndent ?? 0.0
      ..height = (customization?.thickness ?? 1.0) + 16.0;
  }
}

class RenderDivider extends RenderBox {
  RenderDivider({
    required Color color,
    required double thickness,
    required double indent,
    required double endIndent,
    required double height,
  }) : _color = color,
       _thickness = thickness,
       _indent = indent,
       _endIndent = endIndent,
       _height = height;

  Color _color;
  Color get color => _color;
  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  double _thickness;
  double get thickness => _thickness;
  set thickness(double value) {
    if (_thickness == value) return;
    _thickness = value;
    markNeedsLayout();
  }

  double _indent;
  double get indent => _indent;
  set indent(double value) {
    if (_indent == value) return;
    _indent = value;
    markNeedsPaint();
  }

  double _endIndent;
  double get endIndent => _endIndent;
  set endIndent(double value) {
    if (_endIndent == value) return;
    _endIndent = value;
    markNeedsPaint();
  }

  double _height;
  double get height => _height;
  set height(double value) {
    if (_height == value) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.tighten(height: height).biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final ui.Canvas canvas = context.canvas;
    final ui.Paint paint = ui.Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = ui.PaintingStyle.stroke;

    final double midY = offset.dy + size.height / 2;
    final double startX = offset.dx + indent;
    final double endX = offset.dx + size.width - endIndent;

    if (startX < endX) {
      canvas.drawLine(ui.Offset(startX, midY), ui.Offset(endX, midY), paint);
    }
  }
}
