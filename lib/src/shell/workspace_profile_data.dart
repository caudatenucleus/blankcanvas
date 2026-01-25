// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.



class WorkspaceProfileData {
  const WorkspaceProfileData({
    required this.id,
    required this.name,
    this.iconCodePoint,
  });

  final String id;
  final String name;
  final int? iconCodePoint;
}
