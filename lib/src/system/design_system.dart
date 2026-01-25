import 'package:flutter/widgets.dart';

/// A dynamic value that resolves differently based on the current context/theme.
/// Used for colors, spacing, typography, etc.
abstract class ThemeVariable<T> {
  const ThemeVariable();
  T resolve(BuildContext context);
}

/// A static value wrapper for ThemeVariable.
class StaticThemeVariable<T> extends ThemeVariable<T> {
  const StaticThemeVariable(this.value);
  final T value;
  @override
  T resolve(BuildContext context) => value;
}

/// A context-aware value that delegates to a callback.
class ContextThemeVariable<T> extends ThemeVariable<T> {
  const ContextThemeVariable(this.resolver);
  final T Function(BuildContext) resolver;
  @override
  T resolve(BuildContext context) => resolver(context);
}

/// Defines the core configuration for the Design System.
class DesignSystemData {
  const DesignSystemData({this.tokens = const {}, this.variables = const {}});

  /// Raw token map (e.g. loaded from JSON).
  final Map<String, dynamic> tokens;

  /// Runtime variable overrides.
  final Map<String, ThemeVariable> variables;

  DesignSystemData copyWith({
    Map<String, dynamic>? tokens,
    Map<String, ThemeVariable>? variables,
  }) {
    return DesignSystemData(
      tokens: tokens ?? this.tokens,
      variables: variables ?? this.variables,
    );
  }

  T resolve<T>(String key, BuildContext context, {required T defaultValue}) {
    // Check runtime variables first
    if (variables.containsKey(key)) {
      final v = variables[key];
      if (v is ThemeVariable<T>) {
        return v.resolve(context);
      }
    }
    // Fallback to tokens
    if (tokens.containsKey(key)) {
      final val = tokens[key];
      if (val is T) return val;
    }
    return defaultValue;
  }
}

/// The root provider for the Design System.
class DesignSystemProvider extends InheritedWidget {
  const DesignSystemProvider({
    super.key,
    required this.data,
    required super.child,
  });

  final DesignSystemData data;

  static DesignSystemData of(BuildContext context) {
    final DesignSystemProvider? result = context
        .dependOnInheritedWidgetOfExactType<DesignSystemProvider>();
    return result?.data ?? const DesignSystemData();
  }

  @override
  bool updateShouldNotify(DesignSystemProvider oldWidget) {
    return data != oldWidget.data; // Simple identity/equality check
  }
}

/// Utility for loading tokens (Simulation).
class TokenLoader {
  static Future<Map<String, dynamic>> load(String assetPath) async {
    // Simulate async IO
    await Future.delayed(const Duration(milliseconds: 10));
    return {
      'color.primary': 0xFF007AFF,
      'spacing.small': 8.0,
      'spacing.medium': 16.0,
    };
  }
}
