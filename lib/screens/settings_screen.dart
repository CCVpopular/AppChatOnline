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
        title:const Text('Settings'),
        backgroundColor: Colors.transparent, // Màu của AppBar
        elevation: 4.0, // Tạo hiệu ứng đổ bóng cho AppBar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white // Viền trắng khi chế độ tối
                  : Colors.black, // Viền đen khi chế độ sáng
              width: 2.0, // Độ dày của viền
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20), // Bo tròn góc dưới bên trái
              bottomRight: Radius.circular(20), // Bo tròn góc dưới bên phải
              topLeft: Radius.circular(38), // Bo tròn góc trên bên phải
              topRight: Radius.circular(38), // Bo tròn góc trên bên phải
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(207, 70, 131, 180), // Màu thứ hai
                Color.fromARGB(41, 132, 181, 187), // Màu đầu tiên
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nút gạt (Switch) cho Dark/Light Mode
            ListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontSize: 18),
              ),
              trailing: Switch(
                value: context.watch<ThemeNotifier>().themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  final themeNotifier = context.read<ThemeNotifier>();
                  themeNotifier.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
              subtitle:const Text(
                'Customize your theme preferences.',
              ),
            ),
            const Divider(),
            // Thông tin người dùng
            const Text(
              'User Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Username: $username'),
            Text('User ID: $userId'),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading:const Icon(Icons.logout, color: Colors.red),
              title:const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
