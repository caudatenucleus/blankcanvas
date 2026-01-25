// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// Manager for desktop notification stack.
class DesktopNotificationManager extends ChangeNotifier {
  final List<DesktopNotification> _notifications = [];
  final int maxVisibleNotifications;

  DesktopNotificationManager({this.maxVisibleNotifications = 5});

  List<DesktopNotification> get notifications =>
      _notifications.take(maxVisibleNotifications).toList();

  void show(DesktopNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();

    if (notification.duration != null) {
      Future.delayed(notification.duration!, () {
        dismiss(notification.id);
      });
    }
  }

  void dismiss(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void dismissAll() {
    _notifications.clear();
    notifyListeners();
  }
}

class DesktopNotification {
  const DesktopNotification({
    required this.id,
    required this.title,
    this.body,
    this.icon,
    this.duration = const Duration(seconds: 5),
    this.onTap,
    this.actions,
  });

  final String id;
  final String title;
  final String? body;
  final Widget? icon;
  final Duration? duration;
  final VoidCallback? onTap;
  final List<DesktopNotificationAction>? actions;
}

class DesktopNotificationAction {
  const DesktopNotificationAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}
