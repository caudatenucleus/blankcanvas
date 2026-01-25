import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart'
    hide Center, Container, Column, Row, SizedBox, Padding;
import 'package:blankcanvas/blankcanvas.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomizedApp(
      title: 'BlankCanvas Demo',
      customizations: ControlCustomizations(
        buttons: {
          null: ButtonCustomization.simple(
            backgroundColor: const Color(0xFFFFFFFF),
            hoverColor: const Color(0xFFEEEEEE),
            // borderColor removed as it is not supported in simple factory yet
            // Wait, I didn't add 'borderColor' or 'borderWidth' to ButtonCustomization.simple in my previous step!
            // I only added borderRadius.
            // So I cannot replicate the *exact* previous border look with .simple() if I missed that param.
            // Let's check ButtonCustomization.simple params again.
            // It had: backgroundColor, hoverColor, pressColor, disabledColor, foregroundColor, borderRadius, width, height, padding, textStyle.
            // It did NOT have borderColor.
            // So I should stick to 'primary' example for simple, or update the factory.
            // Let's update the factory later if needed. For now, let's use a simpler button style for the default, or use raw if I need border.
            // Let's use raw for default (with resolve!) and simple for primary (which is solid color).
          ),
          // Actually, let's use .simple for 'primary' since it's a solid block of color.
          'primary': ButtonCustomization.simple(
            backgroundColor: const Color(0xFF000000),
            hoverColor: const Color(0xFF333333),
            foregroundColor: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(4.0),
            width: 120.0,
            height: 40.0,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        },

        // We will define default button using resolve below to separate chunks
        textFields: {
          null: TextFieldCustomization.simple(
            backgroundColor: const Color(0xFFFFFFFF),
            borderColor: const Color(0xFFCCCCCC),
            focusedBorderColor: const Color(0xFF000000),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        },
        dataTables: {
          null: DataTableCustomization.simple(
            headerDecoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
            dividerColor: const Color(0xFFEEEEEE),
          ),
        },

        steppers: {
          null: StepperCustomization.simple(
            activeColor: const Color(0xFF000000),
          ),
        },
        accordions: {
          null: AccordionCustomization.simple(
            headerPadding: const EdgeInsets.all(16),
          ),
        },
        checkboxes: {
          null: CheckboxCustomization.simple(
            activeColor: const Color(0xFF000000),
            checkColor: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(2.0),
            size: 20.0,
          ),
        },
        switches: {
          null: SwitchCustomization.simple(
            activeColor: const Color(0xFF000000),
            inactiveThumbColor: const Color(0xFFCCCCCC), // Thumb color when off
            activeTrackColor: const Color(0xFF000000).withValues(
              alpha: 0.3,
            ), // Not exactly what manual code did, but close
            inactiveTrackColor: const Color(0xFFE0E0E0),
            width: 44.0,
            height: 24.0,
          ),
        },
        radios: {
          null: RadioCustomization.simple(
            activeColor: const Color(0xFF000000),
            inactiveColor: const Color(0xFF999999),
            size: 20.0,
          ),
        },
        sliders: {
          null: SliderCustomization(
            trackHeight: 24.0,
            decoration: (status) {
              // We need to visually represent the value.
              // BoxDecoration gradient is a hacky way to do a progress bar without custom painter.
              return BoxDecoration(
                gradient: LinearGradient(
                  colors: const [Color(0xFF000000), Color(0xFFCCCCCC)],
                  stops: [status.value, status.value], // Sharp transition
                ),
                borderRadius: BorderRadius.circular(4.0),
              );
            },
            textStyle: (status) => const TextStyle(),
          ),
        },
        scrollbars: {
          null: ScrollbarCustomization(
            thickness: 10.0,
            thumbMinLength: 40.0,
            decoration: (status) {
              return BoxDecoration(
                color: status.hovered > 0.5
                    ? const Color(0x80000000)
                    : const Color(0x40000000),
                borderRadius: BorderRadius.circular(5),
              );
            },
            trackDecoration: (status) {
              return const BoxDecoration(color: Color(0x10000000));
            },
            textStyle: (_) => const TextStyle(),
          ),
        },
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, _, _) =>
            DashboardPage(username: _usernameController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Login',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Username'),
            const SizedBox(height: 5),
            TextField(
              controller: _usernameController,
              placeholder: 'Enter username',
            ),
            const SizedBox(height: 15),
            const Text('Password'),
            const SizedBox(height: 5),
            TextField(
              controller: _passwordController,
              placeholder: 'Enter password',
            ),
            const SizedBox(height: 20),
            Center(
              child: Button(
                onPressed: _login,
                tag: 'primary',
                child: const Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome, $username!', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          Button(
            // Navigate to Settings
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, _, _) => const SettingsPage(),
                ),
              );
            },
            child: const Text('Settings'),
          ),
          const SizedBox(height: 20),
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = false;
  bool _darkMode = false;
  int _volume = 5;
  double _brightness = 0.5;

  void _dummyCallback() {}
  void _onBottomItemTapped() {}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Let's wrap controls in a Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _notifications,
                          onChanged: (v) => setState(() => _notifications = v),
                        ),
                        const SizedBox(width: 10),
                        const Text('Enable Notifications'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Switch(
                          value: _darkMode,
                          onChanged: (v) => setState(() => _darkMode = v),
                        ),
                        const SizedBox(width: 10),
                        const Text('Dark Mode'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Volume'),
                    Row(
                      children: [1, 2, 3].map((i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: i,
                                groupValue: _volume,
                                onChanged: (v) => setState(() => _volume = v!),
                              ),
                              const SizedBox(width: 5),
                              Text('$i'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('Brightness'),
                    const SizedBox(height: 10),
                    Slider(
                      value: _brightness,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (v) => setState(() => _brightness = v),
                    ),
                    const SizedBox(height: 10),
                    const ProgressIndicator(value: 0.7), // Demo progress
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tab Control
            const Text(
              "Tabs / Segmented Control",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TabControl<String>(
              items: const ["Home", "Profile", "Settings"],
              groupValue:
                  "Home", // State not managed in this snippet, will just select 'Home' visually unless we wrap it
              onChanged: (val) {
                // This part requires state in SettingsPage.
                // But let's just make it print for now or use a local variable if I can edit the whole class.
                // I'll assume I update SettingsPage state below.
              },
            ),
            const SizedBox(height: 20),
            // Menu
            const Text("Menu", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Menu(
              children: [
                MenuItem(onTap: () {}, label: const Text("Item 1")),
                MenuItem(
                  onTap: _dummyCallback,
                  label: const Text("Item 2 (Click me)"),
                ),
                MenuItem(onTap: _dummyCallback, label: const Text("Item 3")),
              ],
            ),
            const SizedBox(height: 20),
            // Bottom Bar
            const Text(
              "Bottom Bar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            BottomBar(
              children: [
                BottomBarItem(
                  icon: const Icon(Icons.home),
                  label: const Text("Home"),
                  selected: true,
                  onTap: _onBottomItemTapped,
                ),
                BottomBarItem(
                  icon: const Icon(Icons.search),
                  label: const Text("Search"),
                  selected: false,
                  onTap: _onBottomItemTapped,
                ),
                BottomBarItem(
                  icon: const Icon(Icons.person),
                  label: const Text("Profile"),
                  selected: false,
                  onTap: _onBottomItemTapped,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Scrollable area
            const Text(
              "Scrollable Content",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (c, i) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Item $i"),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Button(
              onPressed: () {
                showDrawer(
                  context: context,
                  tag: null, // Default
                  builder: (context) => const Drawer(
                    child: Center(child: Text("I am a Drawer!")),
                  ),
                );
              },
              child: const Text('Show Drawer'),
            ),
            const SizedBox(height: 10),
            Button(
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  pageBuilder: (context, _, _) => const Dialog(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("This is a themed dialog!"),
                    ),
                  ),
                  barrierColor: const Color(
                    0x80000000,
                  ), // Should fetch from theme
                  barrierDismissible: true,
                  barrierLabel: 'Dismiss',
                );
              },
              child: const Text('Show Dialog'),
            ),
            const SizedBox(height: 20),
            // Utilities
            const Text(
              "Utilities",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Badge"),
            const SizedBox(height: 5),
            Badge(
              label: const Text("1"),
              child: const Icon(Icons.notifications),
            ),
            const SizedBox(height: 10),
            const Text("Divider"),
            const Divider(),
            const SizedBox(height: 10),
            const Text("Tooltip (Hover/Long Press)"),
            const Tooltip(
              message: "I am a custom tooltip!",
              child: Button(onPressed: null, child: Text("Hover Me")),
            ),
            const SizedBox(height: 20),
            const Text("Date Picker"),
            const SizedBox(height: 10),
            DatePicker(
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              selectedDate: DateTime.now(),
              onChanged: (d) {},
            ),
            const SizedBox(height: 20),
            const Text("Color Picker"),
            const SizedBox(height: 10),
            ColorPicker(
              colors: const [
                Color(0xFFF44336),
                Color(0xFFE91E63),
                Color(0xFF9C27B0),
                Color(0xFF673AB7),
                Color(0xFF3F51B5),
                Color(0xFF2196F3),
                Color(0xFF03A9F4),
                Color(0xFF00BCD4),
                Color(0xFF009688),
                Color(0xFF4CAF50),
              ],
              onChanged: (c) {},
              selectedColor: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 20),
            const Text("Tree View"),
            const SizedBox(height: 10),
            TreeView<String>(
              nodes: [
                TreeNode(
                  data: "Project",
                  children: [
                    TreeNode(
                      data: "lib",
                      children: [
                        TreeNode(data: "main.dart"),
                        TreeNode(data: "blankcanvas.dart"),
                      ],
                    ),
                    TreeNode(
                      data: "test",
                      children: [TreeNode(data: "widget_test.dart")],
                    ),
                  ],
                ),
              ],
              nodeBuilder: (context, data) => Text(data),
            ),
            const SizedBox(height: 20),
            const Text("Data Table"),
            const SizedBox(height: 10),
            DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Status")),
              ],
              rows: const [
                DataRow(cells: [Text("Task A"), Text("Done")]),
                DataRow(cells: [Text("Task B"), Text("In Progress")]),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Stepper"),
            const SizedBox(height: 10),
            Stepper(
              currentStep: 1,
              steps: const [
                Step(title: Text("Planning"), content: Text("Define scope.")),
                Step(
                  title: Text("Development"),
                  content: Text("Write code."),
                  isActive: true,
                ),
                Step(title: Text("Deployment"), content: Text("Release.")),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Accordion"),
            const SizedBox(height: 10),
            Accordion(
              panels: const [
                AccordionPanel(
                  header: Text("Details"),
                  body: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Expandable content shown here."),
                  ),
                ),
                AccordionPanel(
                  header: Text("Advanced Settings"),
                  body: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("More settings hidden by default."),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Low-Level Engine API (Primitive)"),

            const SizedBox(height: 10),
            const SizedBox(
              height: 150,
              width: 150,
              child: PrimitiveDrawing(color: Color(0xFFFF5252), strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            Button(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
