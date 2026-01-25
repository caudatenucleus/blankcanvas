// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:vector_math/vector_math.dart' as vm;


/// 2D Vector wrapper
class Vector2Primitive {
  Vector2Primitive([double x = 0.0, double y = 0.0]) : v = vm.Vector2(x, y);
  Vector2Primitive.fromVector(vm.Vector2 v) : v = v.clone();
  Vector2Primitive.all(double value) : v = vm.Vector2.all(value);
  Vector2Primitive.zero() : v = vm.Vector2.zero();

  final vm.Vector2 v;

  double get x => v.x;
  double get y => v.y;
  set x(double value) => v.x = value;
  set y(double value) => v.y = value;

  double get length => v.length;
  double get length2 => v.length2;

  Vector2Primitive normalize() => Vector2Primitive.fromVector(v.normalized());
  double dot(Vector2Primitive other) => v.dot(other.v);
  double cross(Vector2Primitive other) => v.cross(other.v);

  Vector2Primitive operator +(Vector2Primitive other) =>
      Vector2Primitive.fromVector(v + other.v);
  Vector2Primitive operator -(Vector2Primitive other) =>
      Vector2Primitive.fromVector(v - other.v);
  Vector2Primitive operator *(double scale) =>
      Vector2Primitive.fromVector(v * scale);
}
