// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:ui';


/// Platform dispatcher wrapper
class PlatformDispatcherPrimitive {
  static PlatformDispatcher get instance => PlatformDispatcher.instance;

  static Locale get locale => instance.locale;
  static List<Locale> get locales => instance.locales;
  static double get textScaleFactor => instance.textScaleFactor;
  static Brightness get platformBrightness => instance.platformBrightness;
  static bool get accessibilityFeatures =>
      instance.accessibilityFeatures.accessibleNavigation;
}
