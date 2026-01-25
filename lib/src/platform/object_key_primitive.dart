// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';


class ObjectKeyPrimitive extends ObjectKey {
  const ObjectKeyPrimitive(super.value);
}

// Note: GlobalKey uses factory constructor, cannot be extended directly
// Using composition instead