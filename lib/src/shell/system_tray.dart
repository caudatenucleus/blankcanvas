// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Primitive for system tray integration.
class SystemTrayMenuPrimitive {
  SystemTrayMenuPrimitive({
    required this.iconPath,
    required this.tooltip,
    this.menuItems = const [],
    this.onTrayIconClicked,
  });

  final String iconPath;
  final String tooltip;
  final List<SystemTrayMenuItem> menuItems;
  final VoidCallback? onTrayIconClicked;

  static const MethodChannel _channel = MethodChannel(
    'blankcanvas/system_tray',
  );

  Future<void> show() async {
    try {
      await _channel.invokeMethod('showTray', {
        'iconPath': iconPath,
        'tooltip': tooltip,
        'menuItems': menuItems.map((e) => e.toMap()).toList(),
      });
    } on PlatformException catch (e) {
      debugPrint('SystemTray show failed: $e');
    }
  }

  Future<void> hide() async {
    try {
      await _channel.invokeMethod('hideTray');
    } on PlatformException catch (e) {
      debugPrint('SystemTray hide failed: $e');
    }
  }

  Future<void> updateIcon(String newIconPath) async {
    try {
      await _channel.invokeMethod('updateTrayIcon', {'iconPath': newIconPath});
    } on PlatformException catch (e) {
      debugPrint('SystemTray updateIcon failed: $e');
    }
  }
}

class SystemTrayMenuItem {
  const SystemTrayMenuItem({
    required this.label,
    this.onClicked,
    this.enabled = true,
    this.isSeparator = false,
    this.subMenu,
  });

  final String label;
  final VoidCallback? onClicked;
  final bool enabled;
  final bool isSeparator;
  final List<SystemTrayMenuItem>? subMenu;

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'enabled': enabled,
      'isSeparator': isSeparator,
      'hasSubMenu': subMenu != null,
      'subMenu': subMenu?.map((e) => e.toMap()).toList(),
    };
  }
}
