// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.



/// Spring description wrapper
class SpringDescriptionPrimitive {
  const SpringDescriptionPrimitive({
    required this.mass,
    required this.stiffness,
    required this.damping,
  });

  final double mass;
  final double stiffness;
  final double damping;

  /// Critical damping coefficient
  double get criticalDamping => 2.0 * (mass * stiffness).abs();

  /// Damping ratio
  double get dampingRatio {
    final critical = criticalDamping;
    return critical > 0 ? damping / critical : 0;
  }

  /// Whether the spring is underdamped
  bool get isUnderdamped => dampingRatio < 1.0;

  /// Whether the spring is critically damped
  bool get isCriticallyDamped => (dampingRatio - 1.0).abs() < 0.001;

  /// Whether the spring is overdamped
  bool get isOverdamped => dampingRatio > 1.0;
}
