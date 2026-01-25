// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:vector_math/vector_math.dart' as vm;


/// 2x2 Matrix wrapper
class Matrix2Primitive {
  Matrix2Primitive.identity() : m = vm.Matrix2.identity();
  Matrix2Primitive.zero() : m = vm.Matrix2.zero();
  Matrix2Primitive.columns(vm.Vector2 col0, vm.Vector2 col1)
    : m = vm.Matrix2.columns(col0, col1);

  final vm.Matrix2 m;

  double get determinant => m.determinant();
  Matrix2Primitive transpose() {
    final transposed = m.clone()..transpose();
    return Matrix2Primitive._fromMatrix(transposed);
  }

  Matrix2Primitive._fromMatrix(vm.Matrix2 m) : m = m;
}
