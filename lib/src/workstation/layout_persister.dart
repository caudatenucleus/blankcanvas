// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'dart:convert';
import 'workspace_manager.dart';

/// Serialization logic for workspace state.
class LayoutPersister {
  String save(WorkspaceLayoutConfig config) {
    return jsonEncode(config.toJson());
  }

  WorkspaceLayoutConfig load(String jsonStr) {
    return WorkspaceLayoutConfig.fromJson(jsonDecode(jsonStr));
  }
}
