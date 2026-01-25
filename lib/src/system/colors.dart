import 'package:flutter/widgets.dart';

/// Provides HSL color manipulation utilities.
class HSLColorProvider {
  static HSLColor toHSL(Color color) {
    return HSLColor.fromColor(color);
  }

  static Color fromHSL(HSLColor hsl) {
    return hsl.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = toHSL(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = toHSL(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  static Color saturate(Color color, [double amount = 0.1]) {
    final hsl = toHSL(color);
    final saturation = (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }

  static Color desaturate(Color color, [double amount = 0.1]) {
    final hsl = toHSL(color);
    final saturation = (hsl.saturation - amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }

  static Color invert(Color color) {
    return Color.fromARGB(
      (color.a * 255).round(),
      (255 - (color.r * 255)).round(),
      (255 - (color.g * 255)).round(),
      (255 - (color.b * 255)).round(),
    );
  }
}
