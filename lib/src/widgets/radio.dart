import 'package:flutter/widgets.dart';

import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Radio button.
class RadioStatus extends RadioControlStatus {}

class Radio<T> extends StatefulWidget {
  const Radio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.tag,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? tag;

  @override
  State<Radio<T>> createState() => _RadioState<T>();
}

class _RadioState<T> extends State<Radio<T>> with TickerProviderStateMixin {
  final RadioStatus _status = RadioStatus();

  late final AnimationController _hoverController;
  late final AnimationController _focusController;
  late final AnimationController _selectController;

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
    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _hoverController.addListener(
      () => setState(() {
        _status.hovered = _hoverController.value;
      }),
    );
    _focusController.addListener(
      () => setState(() {
        _status.focused = _focusController.value;
      }),
    );
    _selectController.addListener(
      () => setState(() {
        _status.selected = _selectController.value;
      }),
    );

    _focusNode.addListener(() {
      _focusNode.hasFocus
          ? _focusController.forward()
          : _focusController.reverse();
    });

    _status.enabled = widget.onChanged != null ? 1.0 : 0.0;
    if (widget.value == widget.groupValue) {
      _selectController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(Radio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _status.enabled = widget.onChanged != null ? 1.0 : 0.0;
    if (widget.value == widget.groupValue) {
      _selectController.forward();
    } else {
      _selectController.reverse();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _selectController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged != null) {
      widget.onChanged!(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getRadio(widget.tag);

    if (customization == null) {
      return SizedBox(
        width: 18,
        height: 18,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.value == widget.groupValue
                ? const Color(0xFF000000)
                : const Color(0xFFCCCCCC),
          ),
        ),
      );
    }

    final decoration = customization.decoration(_status);
    final double sizeValue = customization.size ?? 18.0;

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      cursor: widget.onChanged != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _handleTap,
        child: Focus(
          focusNode: _focusNode,
          child: _RadioRenderWidget(
            decoration: decoration is BoxDecoration
                ? decoration
                : const BoxDecoration(shape: BoxShape.circle),
            sizeValue: sizeValue,
          ),
        ),
      ),
    );
  }
}

class _RadioRenderWidget extends LeafRenderObjectWidget {
  const _RadioRenderWidget({required this.decoration, required this.sizeValue});

  final BoxDecoration decoration;
  final double sizeValue;

  @override
  RenderRadio createRenderObject(BuildContext context) {
    return RenderRadio(decoration: decoration, sizeValue: sizeValue);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderRadio renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..sizeValue = sizeValue;
  }
}

class RenderRadio extends RenderBox {
  RenderRadio({required BoxDecoration decoration, required double sizeValue})
    : _decoration = decoration,
      _sizeValue = sizeValue;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  double _sizeValue;
  double get sizeValue => _sizeValue;
  set sizeValue(double value) {
    if (_sizeValue == value) return;
    _sizeValue = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size.square(sizeValue));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFFCCCCCC);

    if (decoration.shape == BoxShape.circle) {
      context.canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
      if (decoration.border != null) {
        decoration.border!.paint(context.canvas, rect, shape: BoxShape.circle);
      }
    } else {
      // Fallback to RRect or Rect if not circle
      if (decoration.borderRadius != null) {
        final borderRadius = decoration.borderRadius!.resolve(
          TextDirection.ltr,
        );
        context.canvas.drawRRect(borderRadius.toRRect(rect), paint);
        if (decoration.border != null) {
          decoration.border!.paint(
            context.canvas,
            rect,
            borderRadius: borderRadius,
          );
        }
      } else {
        context.canvas.drawRect(rect, paint);
        if (decoration.border != null) {
          decoration.border!.paint(context.canvas, rect);
        }
      }
    }
  }
}
