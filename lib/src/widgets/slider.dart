import 'package:flutter/widgets.dart';

import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Slider.
class SliderStatus extends SliderControlStatus {}

class Slider extends StatefulWidget {
  const Slider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.tag,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final String? tag;

  @override
  State<Slider> createState() => _SliderState();
}

class _SliderState extends State<Slider> with TickerProviderStateMixin {
  final SliderStatus _status = SliderStatus();

  late final AnimationController _hoverController;
  late final AnimationController _focusController;
  late final AnimationController _dragController;

  final FocusNode _focusNode = FocusNode();
  final GlobalKey _renderKey = GlobalKey();

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
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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
    _dragController.addListener(
      () => setState(() {
        _status.dragging = _dragController.value;
      }),
    );

    _focusNode.addListener(() {
      _focusNode.hasFocus
          ? _focusController.forward()
          : _focusController.reverse();
    });

    _status.enabled = widget.onChanged != null ? 1.0 : 0.0;
    _updateStatusValue();
  }

  @override
  void didUpdateWidget(Slider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _status.enabled = widget.onChanged != null ? 1.0 : 0.0;
    _updateStatusValue();
  }

  void _updateStatusValue() {
    if (widget.max > widget.min) {
      _status.value = (widget.value - widget.min) / (widget.max - widget.min);
    } else {
      _status.value = 0.0;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _dragController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleDragUpdate(Offset localPosition) {
    if (widget.onChanged != null) {
      final RenderBox? box =
          _renderKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final double width = box.size.width;
        if (width > 0) {
          final double normalized = localPosition.dx.clamp(0.0, width) / width;
          final double newValue =
              widget.min + (normalized * (widget.max - widget.min));
          widget.onChanged!(newValue);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getSlider(widget.tag);

    if (customization == null) {
      return SizedBox(
        height: 20,
        child: ColoredBox(
          color: const Color(0xFFCCCCCC),
          child: FractionallySizedBox(
            widthFactor: _status.value,
            child: const ColoredBox(color: Color(0xFF000000)),
          ),
        ),
      );
    }

    final decoration = customization.decoration(_status);
    final double trackHeight = customization.trackHeight ?? 24.0;

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      cursor: widget.onChanged != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onHorizontalDragStart: (_) {
          _dragController.forward();
          _focusNode.requestFocus();
        },
        onHorizontalDragUpdate: (d) => _handleDragUpdate(d.localPosition),
        onHorizontalDragEnd: (_) => _dragController.reverse(),
        onTapUp: (d) {
          _handleDragUpdate(d.localPosition);
          _focusNode.requestFocus();
        },
        child: Focus(
          focusNode: _focusNode,
          child: _SliderRenderWidget(
            key: _renderKey,
            decoration: decoration is BoxDecoration
                ? decoration
                : const BoxDecoration(),
            trackHeight: trackHeight,
          ),
        ),
      ),
    );
  }
}

class _SliderRenderWidget extends LeafRenderObjectWidget {
  const _SliderRenderWidget({
    super.key,
    required this.decoration,
    required this.trackHeight,
  });

  final BoxDecoration decoration;
  final double trackHeight;

  @override
  RenderSlider createRenderObject(BuildContext context) {
    return RenderSlider(decoration: decoration, trackHeight: trackHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSlider renderObject,
  ) {
    renderObject
      ..decoration = decoration
      ..trackHeight = trackHeight;
  }
}

class RenderSlider extends RenderBox {
  RenderSlider({required BoxDecoration decoration, required double trackHeight})
    : _decoration = decoration,
      _trackHeight = trackHeight;

  BoxDecoration _decoration;
  BoxDecoration get decoration => _decoration;
  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    markNeedsPaint();
  }

  double _trackHeight;
  double get trackHeight => _trackHeight;
  set trackHeight(double value) {
    if (_trackHeight == value) return;
    _trackHeight = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(constraints.maxWidth, trackHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Rect rect = offset & size;
    final Paint paint = Paint()
      ..color = decoration.color ?? const Color(0xFFCCCCCC);

    // Paint track
    if (decoration.borderRadius != null) {
      final borderRadius = decoration.borderRadius!.resolve(TextDirection.ltr);
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

    // Thumb drawing...
    // High-level Slider usually has a thumb. In our case, the decoration built
    // from the status.value (0.0 to 1.0) is expected to show the progress.
  }
}
