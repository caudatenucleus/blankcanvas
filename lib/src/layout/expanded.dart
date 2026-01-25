// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart' hide Expanded, Flexible;
import 'flexible.dart';

/// so that the child fills the available space.
class Expanded extends Flexible {
  const Expanded({super.key, super.flex, required super.child})
    : super(fit: FlexFit.tight);
}
