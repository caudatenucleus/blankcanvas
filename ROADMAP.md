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
- [x] **DataTable**: Themed tables with hover/select row states.
- [x] **Stepper**: Step progress indicators.
- [x] **Accordion**: Collapsible content panels.

### Low-Level Primitives (Engine API)
- [x] **Engine Bridge**: `LeafRenderObjectWidget` utility for raw `dart:ui` access.
- [x] **PrimitiveDrawing**: Initial proof of concept.

---

## 🚧 In Progress / Next Up

### Low-Level Migration
- [x] **Phase 12: Utility Migration**: Move `Divider`, `Badge`, `Card` to raw `RenderObject` implementations.
- [ ] **Phase 13: Layout Migration**: Implement custom `Column`/`Row` equivalents as `MultiChildRenderObjectWidget`.

- [ ] **Phase 14: Input Migration**: Migrate `Button`, `TextField`, `Checkbox` to full `RenderObject` implementations for maximum performance.


### Expansion
- [ ] **Data Tables**: Themed tables with sorting/filtering UI hooks.
- [ ] **Steppers**: Progress wizards.
- [ ] **Accordion/ExpansionPanel**: Collapsible content sections.

### Theming
- [ ] **Dark Mode Generic Preset**: A `defaultDarkTheme()` factory.
- [ ] **High Contrast Preset**: For accessibility.
- [ ] **Material-Like Preset**: A theme that mimics Material Design (to show flexibility).

### DX & Tooling
- [ ] **Theme Builder**: A visual tool or CLI to generate theme code.
- [ ] **Hot Reload Support**: Ensure all customizations update cleanly on hot reload (mostly done, verify edge cases).

## 🔮 Future / Planned

### accessibility
- [ ] **Semantics Audit**: Ensure all custom widgets correctly report Semantics to screen readers.
- [ ] **Keyboard Navigation**: Full arrow-key support for Menus, Grids, and Pickers.

### Testing
- [ ] **Golden Tests**: Visual regression testing for default themes.
- [ ] **Interaction Tests**: Verify tap/hover logic stability.

### Documentation
- [ ] **Widget Catalog**: A visual storybook-style gallery app.
- [ ] **Migration Guide**: Helping users move from Material widgets.
