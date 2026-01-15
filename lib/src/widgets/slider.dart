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
      () => _status.hovered = _hoverController.value,
    );
    _focusController.addListener(
      () => _status.focused = _focusController.value,
    );
    _dragController.addListener(() => _status.dragging = _dragController.value);

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
    // Normalize value to 0.0 - 1.0
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

  void _handleDragStart(DragStartDetails details, double width) {
    _dragController.forward();
    _handleDragUpdate(details.localPosition.dx, width);
    _focusNode.requestFocus();
  }

  void _handleDragUpdate(double dx, double width) {
    if (widget.onChanged != null) {
      final double normalized = dx.clamp(0.0, width) / width;
      final double newValue =
          widget.min + (normalized * (widget.max - widget.min));
      widget.onChanged!(newValue);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragController.reverse();
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

    return ListenableBuilder(
      listenable: _status,
      builder: (context, _) {
        final decoration = customization.decoration(_status);

        return MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          cursor: widget.onChanged != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // Ensure we have some width to drag on
              if (width == 0) return const SizedBox();

              return GestureDetector(
                onHorizontalDragStart: (d) => _handleDragStart(d, width),
                onHorizontalDragUpdate: (d) =>
                    _handleDragUpdate(d.localPosition.dx, width),
                onHorizontalDragEnd: _handleDragEnd,
                onTapUp: (d) {
                  _handleDragStart(
                    DragStartDetails(localPosition: d.localPosition),
                    width,
                  );
                  _handleDragEnd(DragEndDetails());
                },
                child: Focus(
                  focusNode: _focusNode,
                  child: Container(
                    height: customization.trackHeight ?? 24.0,
                    decoration:
                        decoration, // Decoration handles drawing the track and thumb based on _status.value
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
