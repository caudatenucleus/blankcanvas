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
    this.bottomBars = const {},
    this.bottomBarItems = const {},
    this.drawers = const {},
    this.badges = const {},
    this.dividers = const {},
    this.tooltips = const {},
    this.datePickers = const {},
    this.colorPickers = const {},
    this.treeViews = const {},
    this.dataTables = const {},
    this.steppers = const {},
    this.accordions = const {},
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
  final Map<String?, BottomBarCustomization> bottomBars;
  final Map<String?, BottomBarItemCustomization> bottomBarItems;
  final Map<String?, DrawerCustomization> drawers;
  final Map<String?, BadgeCustomization> badges;
  final Map<String?, DividerCustomization> dividers;
  final Map<String?, TooltipCustomization> tooltips;
  final Map<String?, DatePickerCustomization> datePickers;
  final Map<String?, ColorPickerCustomization> colorPickers;
  final Map<String?, TreeViewCustomization> treeViews;
  final Map<String?, DataTableCustomization> dataTables;
  final Map<String?, StepperCustomization> steppers;
  final Map<String?, AccordionCustomization> accordions;

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
  BottomBarCustomization? getBottomBar(String? tag) =>
      bottomBars[tag] ?? bottomBars[null];
  BottomBarItemCustomization? getBottomBarItem(String? tag) =>
      bottomBarItems[tag] ?? bottomBarItems[null];
  DrawerCustomization? getDrawer(String? tag) => drawers[tag] ?? drawers[null];
  BadgeCustomization? getBadge(String? tag) => badges[tag] ?? badges[null];
  DividerCustomization? getDivider(String? tag) =>
      dividers[tag] ?? dividers[null];
  TooltipCustomization? getTooltip(String? tag) =>
      tooltips[tag] ?? tooltips[null];
  DatePickerCustomization? getDatePicker(String? tag) =>
      datePickers[tag] ?? datePickers[null];
  ColorPickerCustomization? getColorPicker(String? tag) =>
      colorPickers[tag] ?? colorPickers[null];
  TreeViewCustomization? getTreeView(String? tag) =>
      treeViews[tag] ?? treeViews[null];
  DataTableCustomization? getDataTable(String? tag) =>
      dataTables[tag] ?? dataTables[null];
  StepperCustomization? getStepper(String? tag) =>
      steppers[tag] ?? steppers[null];
  AccordionCustomization? getAccordion(String? tag) =>
      accordions[tag] ?? accordions[null];

  /// A default theme that provides a standard look for all widgets.
  factory ControlCustomizations.defaultTheme() {
    return ControlCustomizations(
      buttons: {
        null: ButtonCustomization.simple(
          backgroundColor: const Color(0xFF2196F3),
          hoverColor: const Color(0xFF1E88E5),
          pressColor: const Color(0xFF1976D2),
          disabledColor: const Color(0xFFBDBDBD),
          foregroundColor: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      },
      textFields: {
        null: TextFieldCustomization.simple(
          backgroundColor: const Color(0xFFFAFAFA),
          focusedColor: const Color(0xFFFFFFFF),
          borderColor: const Color(0xFFBDBDBD),
          focusedBorderColor: const Color(0xFF2196F3),
          cursorColor: const Color(0xFF2196F3),
          textColor: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(4),
          padding: const EdgeInsets.all(12),
        ),
      },
      checkboxes: {
        null: CheckboxCustomization.simple(
          activeColor: const Color(0xFF2196F3),
          checkColor: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(4),
        ),
      },
      radios: {
        null: RadioCustomization.simple(
          activeColor: const Color(0xFF2196F3),
          inactiveColor: const Color(0xFF757575),
        ),
      },
      switches: {
        null: SwitchCustomization.simple(
          activeColor: const Color(0xFF2196F3),
          activeTrackColor: const Color(0xFFBBDEFB),
          inactiveThumbColor: const Color(0xFFFAFAFA),
          inactiveTrackColor: const Color(0xFFE0E0E0),
          width: 40,
          height: 20,
        ),
      },
      colorPickers: {
        null: ColorPickerCustomization.simple(
          itemCustomization: ColorItemCustomization.simple(
            size: const Size(40, 40),
            margin: const EdgeInsets.all(4),
            selectedBorderColor: const Color(0xFF2196F3),
            borderWidth: 3,
          ),
          spacing: 12,
          runSpacing: 12,
        ),
      },
      treeViews: {
        null: TreeViewCustomization.simple(
          itemCustomization: TreeItemCustomization.simple(
            selectedColor: const Color(0xFFE3F2FD),
            hoverColor: const Color(0xFFF5F5F5),
          ),
        ),
      },
      dataTables: {null: DataTableCustomization.simple()},
      steppers: {null: StepperCustomization.simple()},
      accordions: {null: AccordionCustomization.simple()},
      // Add other defaults as needed or build them manually if simple() is missing
    );
  }
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
