// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Primitive for system native file pickers.
class SystemFilePicker {
  static const MethodChannel _channel = MethodChannel(
    'blankcanvas/file_picker',
  );

  static Future<String?> pickFile({
    String? initialDirectory,
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('pickFile', {
        'initialDirectory': initialDirectory,
        'allowedExtensions': allowedExtensions,
        'dialogTitle': dialogTitle,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('FilePicker pickFile failed: $e');
      return null;
    }
  }

  static Future<List<String>?> pickFiles({
    String? initialDirectory,
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('pickFiles', {
        'initialDirectory': initialDirectory,
        'allowedExtensions': allowedExtensions,
        'dialogTitle': dialogTitle,
      });
      return result?.cast<String>();
    } on PlatformException catch (e) {
      debugPrint('FilePicker pickFiles failed: $e');
      return null;
    }
  }

  static Future<String?> pickDirectory({
    String? initialDirectory,
    String? dialogTitle,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('pickDirectory', {
        'initialDirectory': initialDirectory,
        'dialogTitle': dialogTitle,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('FilePicker pickDirectory failed: $e');
      return null;
    }
  }

  static Future<String?> saveFile({
    String? initialDirectory,
    String? defaultFileName,
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('saveFile', {
        'initialDirectory': initialDirectory,
        'defaultFileName': defaultFileName,
        'allowedExtensions': allowedExtensions,
        'dialogTitle': dialogTitle,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('FilePicker saveFile failed: $e');
      return null;
    }
  }
}
