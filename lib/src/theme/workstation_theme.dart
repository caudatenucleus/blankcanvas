import 'package:flutter/widgets.dart';

/// Defines the color and metrics palette for the Workstation system.
class WorkstationThemeData {
  const WorkstationThemeData({
    this.panelBackground = const Color(0xFFF0F0F0),
    this.panelBorder = const Color(0xFFDDDDDD),
    this.panelShadow = const Color(0x33000000),
    this.dockBackground = const Color(0xFFE0E0E0),
    this.tabActive = const Color(0xFFFFFFFF),
    this.tabInactive = const Color(0xFFEEEEEE),
    this.toolBarBackground = const Color(0xFFFAFAFA),
    this.statusLineBackground = const Color(0xFF333333),
    this.statusLineText = const Color(0xFFCCCCCC),
    this.resizerColor = const Color(0xFFCCCCCC),
  });

  final Color panelBackground;
  final Color panelBorder;
  final Color panelShadow;
  final Color dockBackground;
  final Color tabActive;
  final Color tabInactive;
  final Color toolBarBackground;
  final Color statusLineBackground;
  final Color statusLineText;
  final Color resizerColor;

  static const WorkstationThemeData fallback = WorkstationThemeData();
}

/// InheritedWidget to provide WorkstationThemeData to descendants.
class WorkstationTheme extends InheritedWidget {
  const WorkstationTheme({super.key, required this.data, required super.child});

  final WorkstationThemeData data;

  static WorkstationThemeData of(BuildContext context) {
    final WorkstationTheme? result = context
        .dependOnInheritedWidgetOfExactType<WorkstationTheme>();
    return result?.data ?? WorkstationThemeData.fallback;
  }

  @override
  bool updateShouldNotify(WorkstationTheme oldWidget) {
    return data != oldWidget.data;
  }
}
