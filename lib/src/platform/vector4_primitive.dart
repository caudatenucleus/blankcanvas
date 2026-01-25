// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:vector_math/vector_math.dart' as vm;

/// 4D Vector wrapper
class Vector4Primitive {
  Vector4Primitive([
    double x = 0.0,
    double y = 0.0,
    double z = 0.0,
    double w = 0.0,
  ]) : v = vm.Vector4(x, y, z, w);
  Vector4Primitive.fromVector(vm.Vector4 v) : v = v.clone();
  Vector4Primitive.zero() : v = vm.Vector4.zero();

  final vm.Vector4 v;

  double get x => v.x;
  double get y => v.y;
  double get z => v.z;
  double get w => v.w;

  double get length => v.length;
  Vector4Primitive normalize() => Vector4Primitive.fromVector(v.normalized());
}
