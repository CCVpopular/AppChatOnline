import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Yêu cầu quyền thông báo (chỉ cần cho iOS)
    await _firebaseMessaging.requestPermission();

    // Lấy token của thiết bị để gửi tin nhắn
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Lắng nghe thông báo khi ứng dụng đang mở
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }
    });

    // Lắng nghe khi người dùng nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
    });
  }
}
