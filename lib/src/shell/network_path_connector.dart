// Copyright 2026 The BlankCanvas Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license.

import 'package:flutter/widgets.dart';

/// An authentication wizard for SMB/NFS network paths, using lowest-level RenderObject APIs.
class NetworkPathConnector extends LeafRenderObjectWidget {
  const NetworkPathConnector({
    super.key,
    required this.serverAddress,
    this.useCredentials = true,
  });

  final String serverAddress;
  final bool useCredentials;

  @override
  RenderNetworkPathConnector createRenderObject(BuildContext context) {
    return RenderNetworkPathConnector(
      serverAddress: serverAddress,
      useCredentials: useCredentials,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderNetworkPathConnector renderObject,
  ) {
    renderObject
      ..serverAddress = serverAddress
      ..useCredentials = useCredentials;
  }
}

class RenderNetworkPathConnector extends RenderBox {
  RenderNetworkPathConnector({
    required String serverAddress,
    required bool useCredentials,
  }) : _serverAddress = serverAddress,
       _useCredentials = useCredentials;

  String _serverAddress;
  set serverAddress(String value) {
    if (_serverAddress == value) return;
    _serverAddress = value;
    markNeedsPaint();
  }

  bool _useCredentials;
  set useCredentials(bool value) {
    if (_useCredentials == value) return;
    _useCredentials = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(const Size(400, 200));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = const Color(0xFF2D2D2D));
    // Implementation for connector UI
  }
}
