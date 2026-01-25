// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/gestures.dart';

// =============================================================================
// Pointer Signal Resolver Primitive - Scroll/Zoom competition resolution
// =============================================================================

typedef PointerSignalCallback = void Function(PointerSignalEvent event);

class PointerSignalResolverPrimitive {
  final Map<int, List<PointerSignalCallback>> _registrations = {};
  final Map<int, PointerSignalCallback?> _winners = {};

  void register(int pointer, PointerSignalCallback callback) {
    _registrations.putIfAbsent(pointer, () => []).add(callback);
  }

  void resolve(PointerSignalEvent event) {
    final callbacks = _registrations[event.pointer];
    if (callbacks == null || callbacks.isEmpty) return;

    // First registered callback wins
    if (!_winners.containsKey(event.pointer)) {
      _winners[event.pointer] = callbacks.first;
    }

    final winner = _winners[event.pointer];
    winner?.call(event);
  }

  void clear(int pointer) {
    _registrations.remove(pointer);
    _winners.remove(pointer);
  }
}
