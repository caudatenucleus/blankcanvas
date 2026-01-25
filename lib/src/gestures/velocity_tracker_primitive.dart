// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/gestures.dart';

// =============================================================================
// Core Velocity Tracker Primitive
// =============================================================================

class VelocityTrackerPrimitive {
  VelocityTrackerPrimitive({this.kind = PointerDeviceKind.touch});

  final PointerDeviceKind kind;
  final List<_PointAtTime> _samples = [];
  static const int _maxSamples = 20;
  static const Duration _horizonDuration = Duration(milliseconds: 100);

  void addPosition(Duration time, Offset position) {
    _samples.add(_PointAtTime(time, position));
    if (_samples.length > _maxSamples) {
      _samples.removeAt(0);
    }
  }

  Velocity getVelocity() {
    if (_samples.length < 2) return Velocity.zero;

    // Use least-squares regression for velocity estimation
    final recentSamples = _samples.where((s) {
      final age = _samples.last.time - s.time;
      return age <= _horizonDuration;
    }).toList();

    if (recentSamples.length < 2) return Velocity.zero;

    double xSum = 0, ySum = 0, tSum = 0;
    double xtSum = 0, ytSum = 0, ttSum = 0;

    for (final sample in recentSamples) {
      final t =
          (sample.time - recentSamples.first.time).inMicroseconds / 1000000.0;
      xSum += sample.position.dx;
      ySum += sample.position.dy;
      tSum += t;
      xtSum += sample.position.dx * t;
      ytSum += sample.position.dy * t;
      ttSum += t * t;
    }

    final n = recentSamples.length.toDouble();
    final denominator = n * ttSum - tSum * tSum;

    if (denominator.abs() < 1e-10) return Velocity.zero;

    final vx = (n * xtSum - xSum * tSum) / denominator;
    final vy = (n * ytSum - ySum * tSum) / denominator;

    return Velocity(pixelsPerSecond: Offset(vx, vy));
  }

  void reset() => _samples.clear();
}

class _PointAtTime {
  const _PointAtTime(this.time, this.position);
  final Duration time;
  final Offset position;
}
