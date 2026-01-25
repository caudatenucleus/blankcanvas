// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:vector_math/vector_math.dart' as vm;


/// 3x3 Matrix wrapper
class Matrix3Primitive {
  Matrix3Primitive.identity() : m = vm.Matrix3.identity();
  Matrix3Primitive.zero() : m = vm.Matrix3.zero();
  Matrix3Primitive.rotationZ(double radians)
    : m = vm.Matrix3.rotationZ(radians);

  final vm.Matrix3 m;

  double get determinant => m.determinant();
  Matrix3Primitive invert() {
    final inverted = m.clone()..invert();
    return Matrix3Primitive._fromMatrix(inverted);
  }

  Matrix3Primitive._fromMatrix(vm.Matrix3 m) : m = m;
}
