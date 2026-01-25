// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/foundation.dart';


/// Synchronous future
class SynchronousFuturePrimitive<T> extends SynchronousFuture<T> {
  SynchronousFuturePrimitive(super.value);
}
