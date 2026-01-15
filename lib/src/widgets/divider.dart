import 'package:flutter/widgets.dart';
import '../foundation/status.dart';
import '../theme/theme.dart';

/// Status for a Divider.
class DividerStatus extends DividerControlStatus {}

/// A Divider.
class Divider extends StatelessWidget {
  const Divider({super.key, this.tag});

  final String? tag;

  @override
  Widget build(BuildContext context) {
    final customizations = CustomizedTheme.of(context);
    final customization = customizations.getDivider(tag);

    if (customization == null) {
      return const SizedBox(
        height: 16.0,
        child: Center(
          child: ColoredBox(
            color: Color(0xFFDDDDDD),
            child: SizedBox(height: 1.0, width: double.infinity),
          ),
        ),
      );
    }

    final status = DividerStatus(); // Static

    final decoration = customization.decoration(status);
    final double thickness = customization.thickness ?? 1.0;
    final double indent = customization.indent ?? 0.0;
    final double endIndent = customization.endIndent ?? 0.0;

    return Container(
      height: thickness + 16,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      child: Center(
        child: Container(height: thickness, decoration: decoration),
      ),
    );
  }
}
