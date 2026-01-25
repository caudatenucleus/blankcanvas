// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.



/// Float comparison
class NearEqualPrimitive {
  static bool compare(double a, double b, double epsilon) {
    return (a - b).abs() < epsilon;
  }

  static bool nearZero(double value, [double epsilon = 0.001]) {
    return value.abs() < epsilon;
  }
}

// =============================================================================
// SECTION E: Math Utilities
// =============================================================================
