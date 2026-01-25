// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:vector_math/vector_math.dart' as vm;


/// 3D Vector wrapper
class Vector3Primitive {
  Vector3Primitive([double x = 0.0, double y = 0.0, double z = 0.0])
    : v = vm.Vector3(x, y, z);
  Vector3Primitive.fromVector(vm.Vector3 v) : v = v.clone();
  Vector3Primitive.all(double value) : v = vm.Vector3.all(value);
  Vector3Primitive.zero() : v = vm.Vector3.zero();

  final vm.Vector3 v;

  double get x => v.x;
  double get y => v.y;
  double get z => v.z;

  double get length => v.length;
  Vector3Primitive normalize() => Vector3Primitive.fromVector(v.normalized());
  double dot(Vector3Primitive other) => v.dot(other.v);
  Vector3Primitive cross(Vector3Primitive other) =>
      Vector3Primitive.fromVector(v.cross(other.v));

  Vector3Primitive operator +(Vector3Primitive other) =>
      Vector3Primitive.fromVector(v + other.v);
  Vector3Primitive operator -(Vector3Primitive other) =>
      Vector3Primitive.fromVector(v - other.v);
  Vector3Primitive operator *(double scale) =>
      Vector3Primitive.fromVector(v * scale);
}
