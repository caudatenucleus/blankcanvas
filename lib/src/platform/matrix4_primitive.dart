// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:vector_math/vector_math.dart' as vm;
import 'vector4_primitive.dart';

/// 4x4 Matrix wrapper
class Matrix4Primitive {
  Matrix4Primitive.identity() : m = vm.Matrix4.identity();
  Matrix4Primitive.zero() : m = vm.Matrix4.zero();
  Matrix4Primitive.translation(vm.Vector3 translation)
    : m = vm.Matrix4.translation(translation);
  Matrix4Primitive.rotationX(double radians)
    : m = vm.Matrix4.rotationX(radians);
  Matrix4Primitive.rotationY(double radians)
    : m = vm.Matrix4.rotationY(radians);
  Matrix4Primitive.rotationZ(double radians)
    : m = vm.Matrix4.rotationZ(radians);
  Matrix4Primitive.diagonal3Values(double x, double y, double z)
    : m = vm.Matrix4.diagonal3Values(x, y, z);

  final vm.Matrix4 m;

  double get determinant => m.determinant();
  Matrix4Primitive invert() {
    final inverted = m.clone()..invert();
    return Matrix4Primitive._fromMatrix(inverted);
  }

  Matrix4Primitive operator *(Matrix4Primitive other) =>
      Matrix4Primitive._fromMatrix(m * other.m);

  Vector4Primitive transform(Vector4Primitive v) =>
      Vector4Primitive.fromVector(m.transform(v.v));

  Matrix4Primitive._fromMatrix(vm.Matrix4 m) : m = m;
}
