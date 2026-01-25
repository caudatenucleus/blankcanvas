// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.



/// Tolerance wrapper
class TolerancePrimitive {
  const TolerancePrimitive({
    this.distance = 0.001,
    this.time = 0.001,
    this.velocity = 0.001,
  });

  final double distance;
  final double time;
  final double velocity;

  static const TolerancePrimitive defaultTolerance = TolerancePrimitive();
}
