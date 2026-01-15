import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Progress Indicator.
class ProgressStatus extends ProgressControlStatus {}

class ProgressIndicator extends StatefulWidget {
  const ProgressIndicator({super.key, this.value, this.tag});

  /// The progress value between 0.0 and 1.0. If null, indeterminate.
  final double? value;
  final String? tag;

  @override
  State<ProgressIndicator> createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with TickerProviderStateMixin {
  final ProgressStatus _status = ProgressStatus();

  late final AnimationController _indeterminateController;

  @override
  void initState() {
    super.initState();
    _indeterminateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.value == null) {
      _indeterminateController.repeat();
    }

    _status.progress = widget.value;
  }

  @override
  void didUpdateWidget(ProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _status.progress = widget.value;

    if (widget.value == null && !_indeterminateController.isAnimating) {
      _indeterminateController.repeat();
    } else if (widget.value != null && _indeterminateController.isAnimating) {
      _indeterminateController.stop();
    }
  }

  @override
  void dispose() {
    _indeterminateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getProgressIndicator(widget.tag);

    if (customization == null) {
      // Simple fallback
      return SizedBox(
        height: 4,
        child: ColoredBox(
          color: const Color(0xFFEEEEEE),
          child: FractionallySizedBox(
            widthFactor: widget.value ?? 0.3,
            child: const ColoredBox(color: Color(0xFF000000)),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _status,
      builder: (context, _) {
        final decoration = customization.decoration(_status);

        // If indeterminate, we might want to manually animate the decoration or use a specific painter.
        // For Hixie's architecture, the decoration itself is supposed to react to status.
        // We updated status.progress.
        // For indeterminate, we can use the AnimationController to drive a value in status if we wanted 'spinner position',
        // but base ProgressControlStatus only has 'progress' (nullable).

        return Container(
          height: customization.height ?? 4.0,
          decoration:
              decoration, // The decoration logic in theme needs to handle 'null' progress for indeterminate look
          child: widget.value == null
              ? AnimatedBuilder(
                  animation: _indeterminateController,
                  builder: (context, child) {
                    // This is a bit of a hack to let the theme know about animation phase without dirtying the status too much?
                    // Actually, strict BlankCanvas would put the animation phase into the Status if it affects rendering.
                    // Let's assume for now the decoration just draws a static 'indeterminate' style or handles it internally if it's an AnimatedDecoration.
                    return const SizedBox();
                  },
                )
              : null,
        );
      },
    );
  }
}
