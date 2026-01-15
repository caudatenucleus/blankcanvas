import 'package:flutter/widgets.dart';
import 'blankcanvas.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a basic black-and-white theme for the demo
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
            cursorColor: const Color(0xFF000000),
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
