import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// State object representing the layout configuration.
class WorkspaceLayoutConfig {
  WorkspaceLayoutConfig({required this.panels});

  final Map<String, dynamic> panels; // ID -> Config

  Map<String, dynamic> toJson() => panels;

  static WorkspaceLayoutConfig fromJson(Map<String, dynamic> json) {
    return WorkspaceLayoutConfig(panels: json);
  }
}

/// A manager for window layout state using lowest-level RenderObject APIs.
class WorkspaceManager extends SingleChildRenderObjectWidget {
  const WorkspaceManager({super.key, required super.child, this.initialConfig});

  final WorkspaceLayoutConfig? initialConfig;

  @override
  RenderWorkspaceManager createRenderObject(BuildContext context) {
    return RenderWorkspaceManager(
      config: initialConfig ?? WorkspaceLayoutConfig(panels: {}),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWorkspaceManager renderObject,
  ) {
    // Basic update
  }

  static RenderWorkspaceManager of(BuildContext context) {
    // This is a bit of a hack to find the RenderObject in the tree
    // but without InheritedWidget it's hard.
    // In BlankCanvas, we might have a global registry instead.
    return RenderWorkspaceManager.instance!;
  }
}

class RenderWorkspaceManager extends RenderProxyBox {
  RenderWorkspaceManager({required WorkspaceLayoutConfig config})
    : _config = config {
    instance = this;
  }

  static RenderWorkspaceManager? instance;

  WorkspaceLayoutConfig _config;
  WorkspaceLayoutConfig get config => _config;

  void updateConfig(WorkspaceLayoutConfig newConfig) {
    _config = newConfig;
    markNeedsLayout();
  }

  void registerPanel(String id, Map<String, dynamic> initialData) {
    if (!_config.panels.containsKey(id)) {
      _config.panels[id] = initialData;
      markNeedsLayout();
    }
  }
}
