import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Badge.
class BadgeStatus extends BadgeControlStatus {}

/// A Badge used to decorate a child with a small indicator.
class Badge extends StatelessWidget {
  const Badge({super.key, this.child, this.label, this.tag, this.alignment});

  final Widget? child;
  final Widget? label;
  final String? tag;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return _buildBadge(context);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned(
          top: 0,
          right: 0,
          // We could use the alignment here if provided via customization
          child: _buildBadge(context),
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getBadge(tag);

    if (customization == null) {
      // Fallback
      if (label == null) return const SizedBox();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFFF0000),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 10),
          child: label!,
        ),
      );
    }

    final status = BadgeStatus(); // Static

    final decoration = customization.decoration(status);
    final textStyle = customization.textStyle(status);

    return Container(
      decoration: decoration,
      padding:
          customization.padding ??
          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: label != null
          ? DefaultTextStyle(style: textStyle, child: label!)
          : SizedBox(
              width: (textStyle.fontSize ?? 12) / 2,
              height: (textStyle.fontSize ?? 12) / 2,
            ),
    );
  }
}
