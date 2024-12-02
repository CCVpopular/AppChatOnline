import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Đảm bảo rằng bạn import provider
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../theme/theme_notifier.dart'; // Đảm bảo rằng bạn import ThemeNotifier

class SettingsScreen extends StatelessWidget {
  final String username;
  final String userId;

  const SettingsScreen({Key? key, required this.username, required this.userId}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nút gạt (Switch) cho Dark/Light Mode
            ListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Switch(
                value: context.watch<ThemeNotifier>().themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  // Khi người dùng thay đổi giá trị của Switch, cập nhật theme
                  final themeNotifier = context.read<ThemeNotifier>();
                  themeNotifier.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ),
            Divider(),
            // Thông tin người dùng
            Text(
              'User Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Username: $username'),
            Text('User ID: $userId'),
            SizedBox(height: 20),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
