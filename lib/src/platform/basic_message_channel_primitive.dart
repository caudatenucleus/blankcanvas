// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Basic message channel wrapper
class BasicMessageChannelPrimitive<T> {
  BasicMessageChannelPrimitive(this.name, this.codec);

  final String name;
  final MessageCodec<T> codec;
  late final BasicMessageChannel<T> _channel = BasicMessageChannel<T>(
    name,
    codec,
  );

  Future<T?> send(T message) {
    return _channel.send(message);
  }

  void setMessageHandler(Future<T> Function(T? message)? handler) {
    _channel.setMessageHandler(handler);
  }
}
