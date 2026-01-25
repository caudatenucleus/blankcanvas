// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';


class LabeledGlobalKeyPrimitive {
  LabeledGlobalKeyPrimitive([this.debugLabel]);

  final String? debugLabel;
  final GlobalKey _key = GlobalKey();

  GlobalKey get key => _key;
}
