import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  IO.Socket? socket;

  // Khởi tạo kết nối socket
  void initSocket() {
    socket = IO.io('http://26.39.142.20:3000', IO.OptionBuilder().setTransports(['websocket']).build());
    
    socket!.onConnect((_) {
      print('Connected to server');
    });

    // Nhận toàn bộ tin nhắn khi kết nối
    socket!.on('initMessages', (data) {
      // Xử lý khi nhận tin nhắn ban đầu từ server
    });

    // Nhận tin nhắn mới
    socket!.on('receiveMessage', (data) {
      // Xử lý khi nhận tin nhắn mới từ server
    });
  }

  // Gửi tin nhắn
  void sendMessage(String username, String message) {
    socket!.emit('sendMessage', {
      'username': username,
      'message': message,
    });
  }

  void dispose() {
    socket!.disconnect();
  }
}
