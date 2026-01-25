// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// In Flutter, this is effectively CustomPaint, but exposed as 'Canvas' for semantic parity.
class Canvas extends CustomPaint {
  const Canvas({
    super.key,
    super.painter,
    super.foregroundPainter,
    super.size,
    super.isComplex,
    super.willChange,
    super.child,
  });
}
