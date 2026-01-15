import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import '../foundation/status.dart';
import '../theme/customization.dart';
import '../theme/theme.dart';
import 'layout.dart';

/// A Color Picker widget.
class ColorPicker extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getColorPicker(tag);

    final status = ColorPickerControlStatus();
    final decoration =
        customization?.decoration(status) ?? const BoxDecoration();

    return LayoutBox(
      padding: customization?.padding ?? const EdgeInsets.all(8),
      child: _ColorPickerContainerRenderWidget(
        decoration: decoration is BoxDecoration
            ? decoration
            : const BoxDecoration(),
        child: _ColorGridRenderWidget(
          colors: colors,
          selectedColor: selectedColor,
          customization:
              customization?.itemCustomization ??
              ColorItemCustomization.simple(),
          onColorSelected: onChanged,
          columns: customization?.columns ?? 8,
          spacing: customization?.spacing ?? 8,
          runSpacing: customization?.runSpacing ?? 8,
        ),
      ),
    );
  }
}

class _ColorPickerContainerRenderWidget extends SingleChildRenderObjectWidget {
  const _ColorPickerContainerRenderWidget({
    super.child,
    required this.decoration,
  });
  final BoxDecoration decoration;

  @override
  RenderColorPickerContainer createRenderObject(BuildContext context) =>
      RenderColorPickerContainer(decoration: decoration);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderColorPickerContainer renderObject,
  ) {
    renderObject.decoration = decoration;
  }
}

class RenderColorPickerContainer extends RenderProxyBox {
  RenderColorPickerContainer({required BoxDecoration decoration})
    : _decoration = decoration;
  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0x00000000);
    if (decoration.borderRadius != null) {
      context.canvas.drawRRect(
        decoration.borderRadius!.resolve(TextDirection.ltr).toRRect(rect),
        paint,
      );
    } else {
      context.canvas.drawRect(rect, paint);
    }
    if (child != null) context.paintChild(child!, offset);
  }
}

class _ColorGridRenderWidget extends LeafRenderObjectWidget {
  const _ColorGridRenderWidget({
    required this.colors,
    this.selectedColor,
    required this.customization,
    required this.onColorSelected,
    required this.columns,
    required this.spacing,
    required this.runSpacing,
  });

  final List<Color> colors;
  final Color? selectedColor;
  final ColorItemCustomization customization;
  final ValueChanged<Color> onColorSelected;
  final int columns;
  final double spacing;
  final double runSpacing;

  @override
  RenderColorGrid createRenderObject(BuildContext context) {
    return RenderColorGrid(
      colors: colors,
      selectedColor: selectedColor,
      customization: customization,
      onColorSelected: onColorSelected,
      columns: columns,
      spacing: spacing,
      runSpacing: runSpacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderColorGrid renderObject,
  ) {
    renderObject
      ..colors = colors
      ..selectedColor = selectedColor
      ..customization = customization
      ..onColorSelected = onColorSelected
      ..columns = columns
      ..spacing = spacing
      ..runSpacing = runSpacing;
  }
}

class RenderColorGrid extends RenderBox {
  RenderColorGrid({
    required List<Color> colors,
    Color? selectedColor,
    required ColorItemCustomization customization,
    required this.onColorSelected,
    required int columns,
    required double spacing,
    required double runSpacing,
  }) : _colors = colors,
       _selectedColor = selectedColor,
       _customization = customization,
       _columns = columns,
       _spacing = spacing,
       _runSpacing = runSpacing;

  List<Color> _colors;
  List<Color> get colors => _colors;
  set colors(List<Color> value) {
    _colors = value;
    markNeedsLayout();
  }

  Color? _selectedColor;
  Color? get selectedColor => _selectedColor;
  set selectedColor(Color? value) {
    _selectedColor = value;
    markNeedsPaint();
  }

  ColorItemCustomization _customization;
  ColorItemCustomization get customization => _customization;
  set customization(ColorItemCustomization value) {
    _customization = value;
    markNeedsPaint();
  }

  ValueChanged<Color> onColorSelected;

  int _columns;
  int get columns => _columns;
  set columns(int value) {
    _columns = value;
    markNeedsLayout();
  }

  double _spacing;
  double get spacing => _spacing;
  set spacing(double value) {
    _spacing = value;
    markNeedsLayout();
  }

  double _runSpacing;
  double get runSpacing => _runSpacing;
  set runSpacing(double value) {
    _runSpacing = value;
    markNeedsLayout();
  }

  int? _hoveredIndex;

  @override
  void performLayout() {
    final double itemHeight = customization.size?.height ?? 32;
    final int rows = (colors.length / columns).ceil();
    final double height = rows * itemHeight + (rows - 1) * runSpacing;
    size = constraints.constrain(Size(constraints.maxWidth, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double itemWidth = customization.size?.width ?? 32;
    final double itemHeight = customization.size?.height ?? 32;

    for (int i = 0; i < colors.length; i++) {
      final int row = i ~/ columns;
      final int col = i % columns;
      final Rect itemRect =
          (offset +
              Offset(
                col * (itemWidth + spacing),
                row * (itemHeight + runSpacing),
              )) &
          Size(itemWidth, itemHeight);

      final status = ColorItemControlStatus();
      status.selected = colors[i] == selectedColor ? 1.0 : 0.0;
      status.hovered = _hoveredIndex == i ? 1.0 : 0.0;
      status.enabled = 1.0;

      final decoration = customization.decoration(status);

      // Paint color content
      final Paint contentPaint = Paint()..color = colors[i];
      if (decoration is BoxDecoration && decoration.shape == BoxShape.circle) {
        context.canvas.drawCircle(
          itemRect.center,
          itemRect.width / 2,
          contentPaint,
        );
      } else {
        context.canvas.drawRect(itemRect, contentPaint);
      }

      // Paint decoration (border/overlay)
      if (decoration is BoxDecoration) {
        final Paint borderPaint = Paint()..style = PaintingStyle.stroke;
        if (decoration.border is Border) {
          final border = decoration.border as Border;
          borderPaint.color = border.top.color;
          borderPaint.strokeWidth = border.top.width;

          if (decoration.shape == BoxShape.circle) {
            context.canvas.drawCircle(
              itemRect.center,
              itemRect.width / 2,
              borderPaint,
            );
          } else {
            context.canvas.drawRect(itemRect, borderPaint);
          }
        }
      }
    }
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerHoverEvent || event is PointerDownEvent) {
      final double itemWidth = customization.size?.width ?? 32;
      final double itemHeight = customization.size?.height ?? 32;

      final double x = event.localPosition.dx;
      final double y = event.localPosition.dy;

      final int col = (x / (itemWidth + spacing)).floor();
      final int row = (y / (itemHeight + runSpacing)).floor();

      if (col >= 0 && col < columns) {
        final int index = row * columns + col;
        if (index >= 0 && index < colors.length) {
          // Check if it's actually within the item and not in spacing
          final double localX = x % (itemWidth + spacing);
          final double localY = y % (itemHeight + runSpacing);

          if (localX <= itemWidth && localY <= itemHeight) {
            if (event is PointerHoverEvent) {
              if (_hoveredIndex != index) {
                _hoveredIndex = index;
                markNeedsPaint();
              }
            } else if (event is PointerDownEvent) {
              onColorSelected(colors[index]);
            }
            return;
          }
        }
      }

      if (_hoveredIndex != null) {
        _hoveredIndex = null;
        markNeedsPaint();
      }
    }
    super.handleEvent(event, entry);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}
