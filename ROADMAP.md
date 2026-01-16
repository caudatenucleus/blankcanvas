# BlankCanvas Feature Roadmap

This document outlines the development status and future plans for the BlankCanvas library.

## ✅ Completed

### Architecture
- [x] **Status System**: `ControlStatus` for tracking interaction states (hover, focus, disabled, etc.).
- [x] **Customization System**: `ControlCustomization` for defining visual properties based on status.
- [x] **Theming**: `CustomizedTheme` (InheritedWidget) for propagating customizations.
- [x] **DX Helpers**: `.simple()` factories, `ControlCustomizations.defaultTheme()`, `status.resolve()`.

### Core Widgets
- [x] **Button**: Generic pressable button.
- [x] **TextField**: Input field with focus/hover states.

### Interactive Controls
- [x] **Checkbox**: Boolean selection.
- [x] **Radio**: Group selection.
- [x] **Switch**: Toggle switch.
- [x] **Slider**: Range selection.

### Layout & Navigation
- [x] **Card**: Themed container.
- [x] **Dialog**: Themed modal wrapper.
- [x] **Tabs**: Segmented control/tab bar.
- [x] **Menu**: Popup menus and items.
- [x] **BottomBar**: Navigation bar.
- [x] **Drawer**: Side navigation sheet.
- [x] **Scrollbar**: Custom scrollbar painter.
- [x] **TreeView**: Hierarchical list view.

### Utilities
- [x] **Badge**: Notification indicators.
- [x] **Divider**: Visual separators.
- [x] **Tooltip**: Hover/long-press information.

### Complex Inputs
- [x] **DatePicker**: Month/Date selection grid.
- [x] **ColorPicker**: Color selection grid.

### Expansion Widgets
- [x] **DataTable**: Themed tables with hover/select row states (Migrated to `RenderObject`).
- [x] **Stepper**: Step progress indicators (Migrated to `RenderObject`).
- [x] **Accordion**: Collapsible content panels (Migrated to `RenderObject`).

### Low-Level Primitives (Engine API)
- [x] **Engine Bridge**: `LeafRenderObjectWidget` utility for raw `dart:ui` access.
- [x] **PrimitiveDrawing**: Initial proof of concept.
- [x] **Layout Migration**: `LayoutBox` and `FlexBox` implemented as low-level `RenderObject`s.
- [x] **Input Migration**: `Button`, `TextField`, `Checkbox`, `Radio`, `Switch`, `Slider`, `ProgressIndicator` all migrated to raw `RenderObject`s.

### High-Level UI Primitives (Phase 19)
- [x] **ListTile**: Row primitive with leading/trailing slots.
- [x] **Avatar**: User imagery with status indicators.
- [x] **SearchField**: TextField with clear/search buttons.
- [x] **PageIndicator**: Dot-based pagination indicator.
- [x] **NotificationPopup**: Toast/SnackBar overlay system.

### Theming Ecosystem (Phase 20)
- [x] **defaultDarkTheme()**: Dark mode preset (blue accent on gray).
- [x] **materialLikeTheme()**: MatThe user is frustrated. I was running a command to copy font files, not running the app. But I understand - I need to stop making changes that run things and just focus on code edits. Let me:1. Update pubspec.yaml with font configuration 2. Remove google_fonts dependency3. Update task.md with the new Editor Panel requirements the user described

erial Design-inspired (purple accent, pill buttons).
- [x] **highContrastTheme()**: Accessibility preset (yellow on black).

### Accessibility & Semantics (Phase 21)
- [x] **Semantics Pass**: 8 widgets with screen reader support (Button, Checkbox, Radio, Switch, Slider, TextField, Tabs, ListTile).

### Advanced Widgets (Phase 22)
- [x] **Carousel**: Swipeable pages with PageIndicator integration.
- [x] **Chip**: Selectable tag with avatar and delete button.
- [x] **SegmentedButton**: Multi-select toggle group.
- [x] **SliverHeader**: Collapsible header for CustomScrollView.
- [x] **CollapsibleHeader**: App bar style header with title scaling.

---

## 🚧 In Progress / Next Up

### DX & Tooling
- [ ] **Theme Builder**: A visual tool or CLI to generate theme code.
- [ ] **Hot Reload Support**: Verify edge cases for customization updates.

## 🔮 Future / Planned


### Accessibility
- [ ] **Keyboard Navigation**: Full arrow-key support for Menus, Grids, and Pickers.

### Testing
- [ ] **Golden Tests**: Visual regression testing for default themes.
- [ ] **Interaction Tests**: Verify tap/hover logic stability.

### Documentation
- [ ] **Widget Catalog**: A visual storybook-style gallery app.
- [ ] **Migration Guide**: Helping users move from Material widgets.

