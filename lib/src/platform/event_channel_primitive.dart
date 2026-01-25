// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:async';
import 'package:flutter/services.dart';


/// Event channel wrapper
class EventChannelPrimitive {
  EventChannelPrimitive(this.name, [this.codec = const StandardMethodCodec()]);

  final String name;
  final MethodCodec codec;
  late final EventChannel _channel = EventChannel(name, codec);

  Stream<dynamic> receiveBroadcastStream([dynamic arguments]) {
    return _channel.receiveBroadcastStream(arguments);
  }
}
