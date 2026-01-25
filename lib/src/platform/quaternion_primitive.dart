// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:vector_math/vector_math.dart' as vm;
import 'vector3_primitive.dart';


/// Quaternion wrapper
class QuaternionPrimitive {
  QuaternionPrimitive.identity() : q = vm.Quaternion.identity();
  QuaternionPrimitive.axisAngle(vm.Vector3 axis, double angle)
    : q = vm.Quaternion.axisAngle(axis, angle);
  QuaternionPrimitive.euler(double yaw, double pitch, double roll)
    : q = vm.Quaternion.euler(yaw, pitch, roll);

  final vm.Quaternion q;

  double get length => q.length;
  QuaternionPrimitive normalize() {
    final normalized = q.normalized();
    return QuaternionPrimitive._fromQuat(normalized);
  }

  QuaternionPrimitive operator *(QuaternionPrimitive other) =>
      QuaternionPrimitive._fromQuat(q * other.q);

  Vector3Primitive rotate(Vector3Primitive v) =>
      Vector3Primitive.fromVector(q.rotate(v.v));

  QuaternionPrimitive._fromQuat(vm.Quaternion q) : q = q;
}

// =============================================================================
// SECTION F: Foundation Utilities
// =============================================================================
