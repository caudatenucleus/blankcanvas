// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Method channel wrapper
class MethodChannelPrimitive {
  MethodChannelPrimitive(this.name, [this.codec = const StandardMethodCodec()]);

  final String name;
  final MethodCodec codec;
  late final MethodChannel _channel = MethodChannel(name, codec);

  Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    return _channel.invokeMethod<T>(method, arguments);
  }

  Future<List<T>?> invokeListMethod<T>(String method, [dynamic arguments]) {
    return _channel.invokeListMethod<T>(method, arguments);
  }

  Future<Map<K, V>?> invokeMapMethod<K, V>(String method, [dynamic arguments]) {
    return _channel.invokeMapMethod<K, V>(method, arguments);
  }

  void setMethodCallHandler(
    Future<dynamic> Function(MethodCall call)? handler,
  ) {
    _channel.setMethodCallHandler(handler);
  }
}
