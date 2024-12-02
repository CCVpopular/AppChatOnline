import 'package:appchatonline/screens/home_screen.dart';
import 'package:appchatonline/theme/theme_data.dart';
import 'package:appchatonline/theme/theme_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Lấy trạng thái đăng nhập từ SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userId = prefs.getString('userId') ?? '';

  // Chọn màn hình khởi tạo dựa trên trạng thái đăng nhập
  runApp(MyApp(
    initialScreen: isLoggedIn
        ? MyHomePage(userId: userId) // Chuyển đến màn hình bạn bè nếu đã đăng nhập
        : LoginScreen(), // Chuyển đến màn hình đăng nhập nếu chưa đăng nhập
  ));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), // Cung cấp trạng thái ThemeNotifier
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'Chat App',
            theme: lightTheme, // Theme sáng
            darkTheme: darkTheme, // Theme tối
            themeMode: themeNotifier.themeMode, // Áp dụng chế độ theme
            home: AnimatedSwitcher(
              duration: Duration(milliseconds: 500), // Thời gian chuyển đổi theme
              child: initialScreen, // Màn hình khởi tạo
            ),
          );
        },
      ),
    );
  }
}
