// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/foundation.dart';


/// Observable list
class ObserverListPrimitive<T> {
  final ObserverList<T> _list = ObserverList<T>();

  void add(T listener) => _list.add(listener);
  bool remove(T listener) => _list.remove(listener);
  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;
  Iterable<T> get iterator => _list;
}
