import 'package:flutter/widgets.dart';

/// Defines scaling spacing values.
class DynamicSpacing {
  const DynamicSpacing({this.scale = 1.0});
  final double scale;

  double get xs => 4.0 * scale;
  double get s => 8.0 * scale;
  double get m => 16.0 * scale;
  double get l => 24.0 * scale;
  double get xl => 32.0 * scale;
  double get xxl => 48.0 * scale;

  double custom(double value) => value * scale;
}

/// InheritedWidget to provide DynamicSpacing.
class SpacingProvider extends InheritedWidget {
  const SpacingProvider({
    super.key,
    required this.spacing,
    required super.child,
  });

  final DynamicSpacing spacing;

  static DynamicSpacing of(BuildContext context) {
    final SpacingProvider? result = context
        .dependOnInheritedWidgetOfExactType<SpacingProvider>();
    return result?.spacing ?? const DynamicSpacing();
  }

  @override
  bool updateShouldNotify(SpacingProvider oldWidget) {
    return spacing.scale != oldWidget.spacing.scale;
  }
}
