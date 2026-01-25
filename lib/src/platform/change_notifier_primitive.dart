// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';


/// ChangeNotifier wrapper
class ChangeNotifierPrimitive extends ChangeNotifier {
  void notify() => notifyListeners();
}
