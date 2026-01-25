// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Manager for global system-wide hotkeys.
class GlobalHotkeyManager extends ChangeNotifier {
  final Map<String, GlobalHotkeyBinding> _bindings = {};

  static const MethodChannel _channel = MethodChannel(
    'blankcanvas/global_hotkeys',
  );

  List<GlobalHotkeyBinding> get bindings => _bindings.values.toList();

  Future<bool> register(GlobalHotkeyBinding binding) async {
    try {
      final success = await _channel.invokeMethod<bool>('registerHotkey', {
        'id': binding.id,
        'modifiers': binding.modifiers,
        'keyCode': binding.keyCode,
      });
      if (success == true) {
        _bindings[binding.id] = binding;
        notifyListeners();
        return true;
      }
    } on PlatformException catch (e) {
      debugPrint('GlobalHotkey register failed: $e');
    }
    return false;
  }

  Future<bool> unregister(String id) async {
    try {
      final success = await _channel.invokeMethod<bool>('unregisterHotkey', {
        'id': id,
      });
      if (success == true) {
        _bindings.remove(id);
        notifyListeners();
        return true;
      }
    } on PlatformException catch (e) {
      debugPrint('GlobalHotkey unregister failed: $e');
    }
    return false;
  }

  Future<void> unregisterAll() async {
    for (final id in _bindings.keys.toList()) {
      await unregister(id);
    }
  }
}

class GlobalHotkeyBinding {
  const GlobalHotkeyBinding({
    required this.id,
    required this.modifiers,
    required this.keyCode,
    required this.onTriggered,
    this.description = '',
  });

  final String id;
  final List<String> modifiers;
  final int keyCode;
  final VoidCallback onTriggered;
  final String description;
}
