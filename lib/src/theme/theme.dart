import 'package:flutter/widgets.dart';
export 'customization.dart';
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
    this.listTiles = const {},
    this.avatars = const {},
    this.dropdowns = const {},
    this.ratings = const {},
    this.splitters = const {},
    this.toolbars = const {},
    this.spinners = const {},
    this.carousels = const {},
    this.chips = const {},
    this.segmentedButtons = const {},
    this.headers = const {},
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
  final Map<String?, ListTileCustomization> listTiles;
  final Map<String?, AvatarCustomization> avatars;
  final Map<String?, DropdownCustomization> dropdowns;
  final Map<String?, RatingsCustomization> ratings;
  final Map<String?, SplitterCustomization> splitters;
  final Map<String?, ToolbarCustomization> toolbars;
  final Map<String?, SpinnerCustomization> spinners;
  final Map<String?, CarouselCustomization> carousels;
  final Map<String?, ChipCustomization> chips;
  final Map<String?, SegmentedButtonCustomization> segmentedButtons;
  final Map<String?, HeaderCustomization> headers;

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
  ListTileCustomization? getListTile(String? tag) =>
      listTiles[tag] ?? listTiles[null];
  AvatarCustomization? getAvatar(String? tag) => avatars[tag] ?? avatars[null];
  DropdownCustomization? getDropdown(String? tag) =>
      dropdowns[tag] ?? dropdowns[null];
  RatingsCustomization? getRatings(String? tag) =>
      ratings[tag] ?? ratings[null];
  SplitterCustomization? getSplitter(String? tag) =>
      splitters[tag] ?? splitters[null];
  ToolbarCustomization? getToolbar(String? tag) =>
      toolbars[tag] ?? toolbars[null];
  SpinnerCustomization? getSpinner(String? tag) =>
      spinners[tag] ?? spinners[null];
  CarouselCustomization? getCarousel(String? tag) =>
      carousels[tag] ?? carousels[null];
  ChipCustomization? getChip(String? tag) => chips[tag] ?? chips[null];
  SegmentedButtonCustomization? getSegmentedButton(String? tag) =>
      segmentedButtons[tag] ?? segmentedButtons[null];
  HeaderCustomization? getHeader(String? tag) => headers[tag] ?? headers[null];

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
      listTiles: {null: ListTileCustomization.simple()},
      avatars: {null: AvatarCustomization.simple()},
      dropdowns: {null: DropdownCustomization.simple()},
      ratings: {null: RatingsCustomization.simple()},
      splitters: {null: SplitterCustomization.simple()},
      toolbars: {null: ToolbarCustomization.simple()},
      spinners: {null: SpinnerCustomization.simple()},
      carousels: {null: CarouselCustomization.simple()},
      chips: {null: ChipCustomization.simple()},
      segmentedButtons: {null: SegmentedButtonCustomization.simple()},
      headers: {null: HeaderCustomization.simple()},
    );
  }

  /// A dark theme preset.
  factory ControlCustomizations.defaultDarkTheme() {
    return ControlCustomizations(
      buttons: {
        null: ButtonCustomization.simple(
          backgroundColor: const Color(0xFF1E88E5),
          hoverColor: const Color(0xFF42A5F5),
          pressColor: const Color(0xFF1565C0),
          disabledColor: const Color(0xFF424242),
          foregroundColor: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      },
      textFields: {
        null: TextFieldCustomization.simple(
          backgroundColor: const Color(0xFF303030),
          focusedColor: const Color(0xFF424242),
          borderColor: const Color(0xFF616161),
          focusedBorderColor: const Color(0xFF64B5F6),
          cursorColor: const Color(0xFF64B5F6),
          textColor: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.all(14),
        ),
      },
      checkboxes: {
        null: CheckboxCustomization.simple(
          activeColor: const Color(0xFF64B5F6),
          checkColor: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(4),
        ),
      },
      radios: {
        null: RadioCustomization.simple(
          activeColor: const Color(0xFF64B5F6),
          inactiveColor: const Color(0xFFBDBDBD),
        ),
      },
      switches: {
        null: SwitchCustomization.simple(
          activeColor: const Color(0xFF64B5F6),
          activeTrackColor: const Color(0xFF1E3A5F),
          inactiveThumbColor: const Color(0xFFBDBDBD),
          inactiveTrackColor: const Color(0xFF424242),
          width: 48,
          height: 24,
        ),
      },
      listTiles: {
        null: ListTileCustomization.simple(hoverColor: const Color(0xFF424242)),
      },
      avatars: {
        null: AvatarCustomization.simple(
          backgroundColor: const Color(0xFF424242),
        ),
      },
      dropdowns: {
        null: DropdownCustomization.simple(
          backgroundColor: const Color(0xFF303030),
          borderColor: const Color(0xFF616161),
          textColor: const Color(0xFFE0E0E0),
          menuBackgroundColor: const Color(0xFF424242),
          itemTextColor: const Color(0xFFE0E0E0),
        ),
      },
      ratings: {
        null: RatingsCustomization.simple(
          emptyStarColor: const Color(0xFF616161),
        ),
      },
      splitters: {
        null: SplitterCustomization.simple(
          dividerColor: const Color(0xFF616161),
        ),
      },
      toolbars: {
        null: ToolbarCustomization.simple(
          backgroundColor: const Color(0xFF1565C0),
        ),
      },
      spinners: {
        null: SpinnerCustomization.simple(color: const Color(0xFF64B5F6)),
      },
      carousels: {
        null: CarouselCustomization.simple(
          indicatorColor: const Color(0xFF616161),
          indicatorSelectedColor: const Color(0xFF64B5F6),
        ),
      },
      chips: {
        null: ChipCustomization.simple(
          backgroundColor: const Color(0xFF424242),
          textColor: const Color(0xFFE0E0E0),
          selectedColor: const Color(0xFF616161),
        ),
      },
      segmentedButtons: {
        null: SegmentedButtonCustomization.simple(
          backgroundColor: const Color(0xFF303030),
          borderColor: const Color(0xFF616161),
          textColor: const Color(0xFFE0E0E0),
          selectedColor: const Color(0xFF424242),
        ),
      },
      headers: {
        null: HeaderCustomization.simple(
          backgroundColor: const Color(0xFF1565C0),
        ),
      },
    );
  }

  /// A Material Design-inspired theme preset (warm purple accent).
  factory ControlCustomizations.materialLikeTheme() {
    return ControlCustomizations(
      buttons: {
        null: ButtonCustomization.simple(
          backgroundColor: const Color(0xFF6200EE), // Material Purple
          hoverColor: const Color(0xFF7C4DFF), // Material Deep Purple Accent
          pressColor: const Color(0xFF3700B3),
          disabledColor: const Color(0xFFE0E0E0),
          foregroundColor: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20), // Pill shape
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      },
      textFields: {
        null: TextFieldCustomization.simple(
          backgroundColor: const Color(0xFFFFFFFF),
          focusedColor: const Color(0xFFFFFFFF),
          borderColor: const Color(0xFFBDBDBD),
          focusedBorderColor: const Color(0xFF6200EE),
          cursorColor: const Color(0xFF6200EE),
          textColor: const Color(0xFF212121),
          borderRadius: BorderRadius.circular(4),
          padding: const EdgeInsets.all(16),
        ),
      },
      checkboxes: {
        null: CheckboxCustomization.simple(
          activeColor: const Color(0xFF6200EE),
          checkColor: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(2),
        ),
      },
      radios: {
        null: RadioCustomization.simple(
          activeColor: const Color(0xFF6200EE),
          inactiveColor: const Color(0xFF757575),
        ),
      },
      switches: {
        null: SwitchCustomization.simple(
          activeColor: const Color(0xFF6200EE),
          activeTrackColor: const Color(0xFFBB86FC),
          inactiveThumbColor: const Color(0xFFFAFAFA),
          inactiveTrackColor: const Color(0xFFBDBDBD),
          width: 36,
          height: 18,
        ),
      },
      listTiles: {null: ListTileCustomization.simple()},
      avatars: {null: AvatarCustomization.simple()},
      dataTables: {null: DataTableCustomization.simple()},
      steppers: {null: StepperCustomization.simple()},
      accordions: {null: AccordionCustomization.simple()},
      dropdowns: {null: DropdownCustomization.simple()},
      ratings: {
        null: RatingsCustomization.simple(starColor: const Color(0xFFFFC107)),
      },
      splitters: {null: SplitterCustomization.simple()},
      toolbars: {
        null: ToolbarCustomization.simple(
          backgroundColor: const Color(0xFF6200EE),
        ),
      },
      spinners: {
        null: SpinnerCustomization.simple(color: const Color(0xFF6200EE)),
      },
      carousels: {
        null: CarouselCustomization.simple(
          indicatorSelectedColor: const Color(0xFF6200EE),
        ),
      },
      chips: {
        null: ChipCustomization.simple(
          selectedColor: const Color(0xFF6200EE),
          selectedTextColor: const Color(0xFFFFFFFF),
        ),
      },
      segmentedButtons: {
        null: SegmentedButtonCustomization.simple(
          selectedColor: const Color(0xFFE1BEE7),
          borderColor: const Color(0xFF6200EE),
          selectedTextColor: const Color(0xFF6200EE),
        ),
      },
      headers: {
        null: HeaderCustomization.simple(
          backgroundColor: const Color(0xFF6200EE),
        ),
      },
    );
  }

  /// A high contrast theme for accessibility.
  factory ControlCustomizations.highContrastTheme() {
    return ControlCustomizations(
      buttons: {
        null: ButtonCustomization.simple(
          backgroundColor: const Color(0xFF000000),
          hoverColor: const Color(0xFF333333),
          pressColor: const Color(0xFF000000),
          disabledColor: const Color(0xFF666666),
          foregroundColor: const Color(0xFFFFFF00), // Yellow on black
          borderRadius: BorderRadius.circular(0), // Sharp corners
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      },
      textFields: {
        null: TextFieldCustomization.simple(
          backgroundColor: const Color(0xFF000000),
          focusedColor: const Color(0xFF000000),
          borderColor: const Color(0xFFFFFFFF),
          focusedBorderColor: const Color(0xFFFFFF00),
          cursorColor: const Color(0xFFFFFF00),
          textColor: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(0),
          padding: const EdgeInsets.all(14),
        ),
      },
      checkboxes: {
        null: CheckboxCustomization.simple(
          activeColor: const Color(0xFF000000),
          checkColor: const Color(0xFFFFFF00),
          borderRadius: BorderRadius.circular(0),
        ),
      },
      radios: {
        null: RadioCustomization.simple(
          activeColor: const Color(0xFFFFFF00),
          inactiveColor: const Color(0xFFFFFFFF),
        ),
      },
      switches: {
        null: SwitchCustomization.simple(
          activeColor: const Color(0xFFFFFF00),
          activeTrackColor: const Color(0xFF000000),
          inactiveThumbColor: const Color(0xFFFFFFFF),
          inactiveTrackColor: const Color(0xFF333333),
          width: 52,
          height: 28,
        ),
      },
      listTiles: {
        null: ListTileCustomization.simple(hoverColor: const Color(0xFF333333)),
      },
      avatars: {
        null: AvatarCustomization.simple(
          backgroundColor: const Color(0xFF333333),
        ),
      },
      dataTables: {null: DataTableCustomization.simple()},
      steppers: {null: StepperCustomization.simple()},
      accordions: {null: AccordionCustomization.simple()},
      dropdowns: {
        null: DropdownCustomization.simple(
          backgroundColor: const Color(0xFF000000),
          borderColor: const Color(0xFFFFFFFF),
          textColor: const Color(0xFFFFFFFF),
        ),
      },
      ratings: {
        null: RatingsCustomization.simple(
          starColor: const Color(0xFFFFFF00),
          emptyStarColor: const Color(0xFFFFFFFF),
        ),
      },
      splitters: {
        null: SplitterCustomization.simple(
          dividerColor: const Color(0xFFFFFFFF),
        ),
      },
      toolbars: {
        null: ToolbarCustomization.simple(
          backgroundColor: const Color(0xFF000000),
          foregroundColor: const Color(0xFFFFFF00),
        ),
      },
      spinners: {
        null: SpinnerCustomization.simple(color: const Color(0xFFFFFF00)),
      },
      carousels: {
        null: CarouselCustomization.simple(
          indicatorColor: const Color(0xFFFFFFFF),
          indicatorSelectedColor: const Color(0xFFFFFF00),
        ),
      },
      chips: {
        null: ChipCustomization.simple(
          backgroundColor: const Color(0xFF000000),
          textColor: const Color(0xFFFFFFFF),
          selectedColor: const Color(0xFFFFFF00),
          selectedTextColor: const Color(0xFF000000),
        ),
      },
      segmentedButtons: {
        null: SegmentedButtonCustomization.simple(
          backgroundColor: const Color(0xFF000000),
          borderColor: const Color(0xFFFFFFFF),
          textColor: const Color(0xFFFFFFFF),
          selectedColor: const Color(0xFFFFFF00),
          selectedTextColor: const Color(0xFF000000),
        ),
      },
      headers: {
        null: HeaderCustomization.simple(
          backgroundColor: const Color(0xFF000000),
          foregroundColor: const Color(0xFFFFFF00),
        ),
      },
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
