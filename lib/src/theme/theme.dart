import 'package:flutter/widgets.dart';
import 'customization.dart';

/// A collection of customizations for all controls in the app.
class ControlCustomizations {
  const ControlCustomizations({
    this.buttons = const {},
    this.textFields = const {},
    this.checkboxes = const {},
    this.radios = const {},
    this.switches = const {},
    this.sliders = const {},
    this.cards = const {},
    this.progressIndicators = const {},
    this.dialogs = const {},
    this.scrollbars = const {},
    this.tabs = const {},
    this.menus = const {},
    this.menuItems = const {},
  });

  /// Map of button tags to their customization. Null key is the default.
  final Map<String?, ButtonCustomization> buttons;

  /// Map of text field tags to their customization. Null key is the default.
  final Map<String?, TextFieldCustomization> textFields;

  final Map<String?, CheckboxCustomization> checkboxes;
  final Map<String?, RadioCustomization> radios;
  final Map<String?, SwitchCustomization> switches;
  final Map<String?, SliderCustomization> sliders;

  final Map<String?, CardCustomization> cards;
  final Map<String?, ProgressCustomization> progressIndicators;
  final Map<String?, DialogCustomization> dialogs;
  final Map<String?, ScrollbarCustomization> scrollbars;
  final Map<String?, TabCustomization> tabs;
  final Map<String?, MenuCustomization> menus;
  final Map<String?, MenuItemCustomization> menuItems;

  ButtonCustomization? getButton(String? tag) => buttons[tag] ?? buttons[null];
  TextFieldCustomization? getTextField(String? tag) =>
      textFields[tag] ?? textFields[null];
  CheckboxCustomization? getCheckbox(String? tag) =>
      checkboxes[tag] ?? checkboxes[null];
  RadioCustomization? getRadio(String? tag) => radios[tag] ?? radios[null];
  SwitchCustomization? getSwitch(String? tag) =>
      switches[tag] ?? switches[null];
  SliderCustomization? getSlider(String? tag) => sliders[tag] ?? sliders[null];
  CardCustomization? getCard(String? tag) => cards[tag] ?? cards[null];
  ProgressCustomization? getProgressIndicator(String? tag) =>
      progressIndicators[tag] ?? progressIndicators[null];
  DialogCustomization? getDialog(String? tag) => dialogs[tag] ?? dialogs[null];
  ScrollbarCustomization? getScrollbar(String? tag) =>
      scrollbars[tag] ?? scrollbars[null];
  TabCustomization? getTab(String? tag) => tabs[tag] ?? tabs[null];
  MenuCustomization? getMenu(String? tag) => menus[tag] ?? menus[null];
  MenuItemCustomization? getMenuItem(String? tag) =>
      menuItems[tag] ?? menuItems[null];
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
