import 'package:flutter/widgets.dart';
import 'customization.dart';

/// A collection of customizations for all controls in the app.
class ControlCustomizations {
  const ControlCustomizations({
    this.buttons = const {},
    this.textFields = const {},
  });

  /// Map of button tags to their customization. Null key is the default.
  final Map<String?, ButtonCustomization> buttons;

  /// Map of text field tags to their customization. Null key is the default.
  final Map<String?, TextFieldCustomization> textFields;

  ButtonCustomization? getButton(String? tag) => buttons[tag] ?? buttons[null];
  TextFieldCustomization? getTextField(String? tag) =>
      textFields[tag] ?? textFields[null];
}

/// An [InheritedWidget] that provides [ControlCustomizations] to its descendants.
class CustomizedTheme extends InheritedWidget {
  const CustomizedTheme({super.key, required this.data, required super.child});

  final ControlCustomizations data;

  static ControlCustomizations of(BuildContext context) {
    final CustomizedTheme? result = context
        .dependOnInheritedWidgetOfExactType<CustomizedTheme>();
    if (result == null) {
      // Return mostly empty default if not found, or throw.
      // For robustness, returning a default empty set is often safer
      // but might lead to invisible widgets if not handled.
      return const ControlCustomizations();
    }
    return result.data;
  }

  @override
  bool updateShouldNotify(CustomizedTheme oldWidget) => data != oldWidget.data;
}

/// A wrapper app that injects the theme.
class CustomizedApp extends StatelessWidget {
  const CustomizedApp({
    super.key,
    required this.customizations,
    required this.home,
    this.title = '',
  });

  final ControlCustomizations customizations;
  final Widget home;
  final String title;

  @override
  Widget build(BuildContext context) {
    return CustomizedTheme(
      data: customizations,
      child: WidgetsApp(
        title: title,
        color: const Color(0xFF000000), // Default system color
        debugShowCheckedModeBanner: false,
        pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
          return PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                builder(context),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return child;
                },
          );
        },
        home: Builder(
          builder: (innerContext) {
            return DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'sans-serif',
                color: Color(0xFF000000),
                fontSize: 14.0,
                decoration: TextDecoration.none,
              ),
              child: home,
            );
          },
        ),
      ),
    );
  }
}
