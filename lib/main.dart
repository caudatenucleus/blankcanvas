import 'package:flutter/widgets.dart';
import 'blankcanvas.dart';

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
          null: ButtonCustomization(
            decoration: (status) {
              return BoxDecoration(
                color: status.hovered > 0.5
                    ? const Color(0xFFEEEEEE)
                    : const Color(0xFFFFFFFF),
                border: Border.all(color: const Color(0xFF000000), width: 1.0),
              );
            },
            textStyle: (status) {
              return const TextStyle(
                color: Color(0xFF000000),
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              );
            },
            width: 120.0,
            height: 40.0,
          ),
          'primary': ButtonCustomization(
            decoration: (status) {
              return BoxDecoration(
                color: status.hovered > 0.5
                    ? const Color(0xFF000000).withValues(alpha: 0.8)
                    : const Color(0xFF000000),
                borderRadius: BorderRadius.circular(4.0),
              );
            },
            textStyle: (status) {
              return const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              );
            },
            width: 120.0,
            height: 40.0,
          ),
        },
        textFields: {
          null: TextFieldCustomization(
            decoration: (status) {
              final isFocused = status.focused > 0.5;
              return BoxDecoration(
                color: const Color(0xFFFFFFFF),
                border: Border.all(
                  color: isFocused
                      ? const Color(0xFF000000)
                      : const Color(0xFFCCCCCC),
                  width: isFocused ? 2.0 : 1.0,
                ),
              );
            },
            textStyle: (status) {
              return const TextStyle(color: Color(0xFF000000), fontSize: 14.0);
            },
          ),
        },
        checkboxes: {
          null: CheckboxCustomization(
            size: 20.0,
            decoration: (status) {
              return BoxDecoration(
                color: status.checked > 0.5
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
                border: Border.all(color: const Color(0xFF000000)),
                borderRadius: BorderRadius.circular(2.0),
              );
            },
            textStyle: (status) => const TextStyle(),
          ),
        },
        switches: {
          null: SwitchCustomization(
            width: 44.0,
            height: 24.0,
            decoration: (status) {
              // Draw a simple track and thumb
              // We can't really draw a complex shape with just BoxDecoration,
              // usually we'd use a CustomPainter in the decoration or just simplified visuals.
              // Here we just change color for the whole box to represent state.
              return BoxDecoration(
                color: status.checked > 0.5
                    ? const Color(0xFF000000)
                    : const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFF000000), width: 1.0),
              );
            },
            textStyle: (status) => const TextStyle(),
          ),
        },
        radios: {
          null: RadioCustomization(
            size: 20.0,
            decoration: (status) {
              return BoxDecoration(
                shape: BoxShape.circle,
                color: status.selected > 0.5
                    ? const Color(0xFF000000)
                    : const Color(0xFFFFFFFF),
                border: Border.all(color: const Color(0xFF000000)),
              );
            },
            textStyle: (status) => const TextStyle(),
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
                const MenuItem(onPressed: null, child: Text("Item 1")),
                MenuItem(
                  onPressed: _dummyCallback,
                  child: const Text("Item 2 (Click me)"),
                ),
                MenuItem(
                  onPressed: _dummyCallback,
                  child: const Text("Item 3"),
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
