// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

/// Gesture Arena Primitive - Low-level win/loss gesture resolution
library;

import 'package:flutter/gestures.dart';

abstract class GestureArenaMemberPrimitive {
  void acceptGesture(int pointer);
  void rejectGesture(int pointer);
}

class GestureArenaEntryPrimitive {
  GestureArenaEntryPrimitive._(this._arena, this._pointer, this._member);

  final GestureArenaPrimitive _arena;
  final int _pointer;
  final GestureArenaMemberPrimitive _member;

  void resolve(GestureDisposition disposition) {
    _arena._resolve(_pointer, _member, disposition);
  }
}

class GestureArenaPrimitive {
  final Map<int, _GestureArenaState> _arenas = {};

  GestureArenaEntryPrimitive add(
    int pointer,
    GestureArenaMemberPrimitive member,
  ) {
    final state = _arenas.putIfAbsent(pointer, () => _GestureArenaState());
    state.members.add(member);
    return GestureArenaEntryPrimitive._(this, pointer, member);
  }

  void close(int pointer) {
    final state = _arenas[pointer];
    if (state != null) {
      state.isOpen = false;
      _tryResolve(pointer);
    }
  }

  void sweep(int pointer) {
    final state = _arenas[pointer];
    if (state == null) return;

    if (state.members.isNotEmpty) {
      state.members.first.acceptGesture(pointer);
      for (int i = 1; i < state.members.length; i++) {
        state.members[i].rejectGesture(pointer);
      }
    }
    _arenas.remove(pointer);
  }

  void _resolve(
    int pointer,
    GestureArenaMemberPrimitive member,
    GestureDisposition disposition,
  ) {
    final state = _arenas[pointer];
    if (state == null) return;

    if (disposition == GestureDisposition.accepted) {
      for (final m in state.members) {
        if (m == member) {
          m.acceptGesture(pointer);
        } else {
          m.rejectGesture(pointer);
        }
      }
      _arenas.remove(pointer);
    } else {
      state.members.remove(member);
      member.rejectGesture(pointer);
      _tryResolve(pointer);
    }
  }

  void _tryResolve(int pointer) {
    final state = _arenas[pointer];
    if (state == null || state.isOpen) return;

    if (state.members.length == 1) {
      state.members.first.acceptGesture(pointer);
      _arenas.remove(pointer);
    } else if (state.members.isEmpty) {
      _arenas.remove(pointer);
    }
  }
}

class _GestureArenaState {
  final List<GestureArenaMemberPrimitive> members = [];
  bool isOpen = true;
}
