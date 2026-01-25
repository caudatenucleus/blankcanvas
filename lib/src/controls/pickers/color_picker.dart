import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';

import 'package:blankcanvas/src/foundation/status.dart';
import 'package:blankcanvas/src/theme/theme.dart';

/// A Color Picker widget.
class ColorPicker extends LeafRenderObjectWidget {
  const ColorPicker({
    super.key,
    required this.colors,
    this.selectedColor,
    required this.onChanged,
    this.tag,
  });

  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onChanged;
  final String? tag;

  @override
  RenderColorPicker createRenderObject(BuildContext context) {
    final customization = CustomizedTheme.of(context).getColorPicker(tag);
    return RenderColorPicker(
      colors: colors,
      selectedColor: selectedColor,
      onChanged: onChanged,
      customization: customization,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderColorPicker renderObject,
  ) {
    final customization = CustomizedTheme.of(context).getColorPicker(tag);
    renderObject
      ..colors = colors
      ..selectedColor = selectedColor
      ..onChanged = onChanged
      ..customization = customization;
  }
}

class RenderColorPicker extends RenderBox {
  RenderColorPicker({
    required List<Color> colors,
    Color? selectedColor,
    required ValueChanged<Color> onChanged,
    ColorPickerCustomization? customization,
  }) : _colors = colors,
       _selectedColor = selectedColor,
       _onChanged = onChanged,
       _customization = customization {
    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  List<Color> _colors;
  set colors(List<Color> value) {
    if (_colors != value) {
      _colors = value;
      markNeedsLayout();
    }
  }

  Color? _selectedColor;
  set selectedColor(Color? value) {
    if (_selectedColor != value) {
      _selectedColor = value;
      markNeedsPaint();
    }
  }

  ValueChanged<Color> _onChanged;
  set onChanged(ValueChanged<Color> value) {
    _onChanged = value;
  }

  ColorPickerCustomization? _customization;
  set customization(ColorPickerCustomization? value) {
    if (_customization != value) {
      _customization = value;
      markNeedsLayout();
    }
  }

  late TapGestureRecognizer _tap;
  int? _hoveredIndex;

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  @override
  void performLayout() {
    final cust = _customization ?? ColorPickerCustomization.simple();
    final padding =
        cust.padding?.resolve(TextDirection.ltr) ?? const EdgeInsets.all(8);
    final columns = cust.columns ?? 8;
    final spacing = cust.spacing ?? 8;
    final runSpacing = cust.runSpacing ?? 8;
    final itemSize = cust.itemCustomization.size ?? const Size(32, 32);

    final totalHSpacing = (columns - 1) * spacing;
    final contentW = (columns * itemSize.width) + totalHSpacing;

    // We try to fit into constraints.maxWidth
    double actualW = constraints.maxWidth;
    if (actualW.isInfinite) actualW = contentW + padding.horizontal;

    // Rows
    final rows = (_colors.length / columns).ceil();
    final totalVSpacing = (rows > 0 ? rows - 1 : 0) * runSpacing;
    final contentH = (rows * itemSize.height) + totalVSpacing;

    size = constraints.constrain(Size(actualW, contentH + padding.vertical));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final cust = _customization ?? ColorPickerCustomization.simple();
    final padding =
        cust.padding?.resolve(TextDirection.ltr) ?? const EdgeInsets.all(8);
    final columns = cust.columns ?? 8;
    final spacing = cust.spacing ?? 8;
    final runSpacing = cust.runSpacing ?? 8;
    final itemSize = cust.itemCustomization.size ?? const Size(32, 32);
    final itemCust = cust.itemCustomization;

    // Bg
    final status = ColorPickerControlStatus();
    final decoration = cust.decoration(status);
    if (decoration is BoxDecoration) {
      final paint = Paint()
        ..color = decoration.color ?? const Color(0x00000000);
      context.canvas.drawRect(
        offset & size,
        paint,
      ); // Should draw border logic too if any
      // Keeping it simple for now
    }

    final startOffset = offset + Offset(padding.left, padding.top);

    for (int i = 0; i < _colors.length; i++) {
      final int row = i ~/ columns;
      final int col = i % columns;

      final dx = col * (itemSize.width + spacing);
      final dy = row * (itemSize.height + runSpacing);
      final itemRect = (startOffset + Offset(dx, dy)) & itemSize;

      final itemStatus = ColorItemControlStatus();
      itemStatus.selected = _colors[i] == _selectedColor ? 1.0 : 0.0;
      itemStatus.hovered = _hoveredIndex == i ? 1.0 : 0.0;
      itemStatus.enabled = 1.0;

      final itemDec = itemCust.decoration(itemStatus);

      final contentPaint = Paint()..color = _colors[i];
      if (itemDec is BoxDecoration) {
        if (itemDec.shape == BoxShape.circle) {
          context.canvas.drawCircle(
            itemRect.center,
            itemRect.width / 2,
            contentPaint,
          );
        } else {
          context.canvas.drawRect(itemRect, contentPaint);
        }

        // Border/Stroke
        if (itemDec.border is Border) {
          final border = itemDec.border as Border;
          final borderPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = border.top.width
            ..color = border.top.color;
          if (itemDec.shape == BoxShape.circle) {
            context.canvas.drawCircle(
              itemRect.center,
              itemRect.width / 2,
              borderPaint,
            );
          } else {
            context.canvas.drawRect(itemRect, borderPaint);
          }
        }
      } else {
        context.canvas.drawRect(itemRect, contentPaint);
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _hitTestItem(details.localPosition, (index) {
      _onChanged(_colors[index]);
    });
  }

  void _handleHover(PointerHoverEvent event) {
    bool found = _hitTestItem(event.localPosition, (index) {
      if (_hoveredIndex != index) {
        _hoveredIndex = index;
        markNeedsPaint();
      }
    });
    if (!found && _hoveredIndex != null) {
      _hoveredIndex = null;
      markNeedsPaint();
    }
  }

  bool _hitTestItem(Offset local, Function(int) onHit) {
    final cust = _customization ?? ColorPickerCustomization.simple();
    final padding =
        cust.padding?.resolve(TextDirection.ltr) ?? const EdgeInsets.all(8);
    final columns = cust.columns ?? 8;
    final spacing = cust.spacing ?? 8;
    final runSpacing = cust.runSpacing ?? 8;
    final itemSize = cust.itemCustomization.size ?? const Size(32, 32);

    // Effective content area
    if (local.dx < padding.left || local.dy < padding.top) return false;

    final relX = local.dx - padding.left;
    final relY = local.dy - padding.top;

    final col = (relX / (itemSize.width + spacing)).floor();
    final row = (relY / (itemSize.height + runSpacing)).floor();

    if (col < 0 || col >= columns) return false;

    final index = row * columns + col;
    if (index >= 0 && index < _colors.length) {
      // Check exact rect
      final itemLeft = col * (itemSize.width + spacing);
      final itemTop = row * (itemSize.height + runSpacing);
      if (relX >= itemLeft &&
          relX <= itemLeft + itemSize.width &&
          relY >= itemTop &&
          relY <= itemTop + itemSize.height) {
        onHit(index);
        return true;
      }
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
    } else if (event is PointerHoverEvent) {
      _handleHover(event);
    }
  }
}
