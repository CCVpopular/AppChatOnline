import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  final _messageStreamController = StreamController<Map<String, String>>.broadcast();
  final String userId;
  final String friendId;

  ChatService(this.userId, this.friendId) {
    _connectSocket();
  }

  // Kết nối socket và lắng nghe sự kiện
  void _connectSocket() {
    socket = IO.io(
      'http://26.24.143.103:3000',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.onConnect((_) {
      print('Connected to server');

      // Tham gia phòng chat
      socket.emit('joinRoom', {
        'userId': userId,
        'friendId': friendId,
      });
    });

    // Lắng nghe sự kiện nhận tin nhắn
    socket.on('receiveMessage', (data) {
      if (data['sender'] != userId) {
        _messageStreamController.add({
          'sender': data['sender'],
          'message': data['message'],
        });
      }
    });
  }

  // Hàm gửi tin nhắn
  void sendMessage(String message) {
    socket.emit('sendMessage', {
      'sender': userId,
      'receiver': friendId,
      'message': message,
    });

    // Thêm tin nhắn vào Stream ngay lập tức
    _messageStreamController.add({
      'sender': userId,
      'message': message,
    });
  }

  // Hàm lấy tin nhắn cũ
  Future<List<Map<String, String>>> loadMessages() async {
    final url = Uri.parse('http://26.24.143.103:3000/api/messages/messages/$userId/$friendId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((msg) {
          return {
            'sender': msg['sender'].toString(),
            'message': msg['message'].toString(),
          };
        }).toList();
      } else {
        throw Exception('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }

  // Stream để lắng nghe tin nhắn
  Stream<Map<String, String>> get messageStream => _messageStreamController.stream;

  // Đóng Stream và Socket
  void dispose() {
    socket.emit('leaveRoom', {
      'userId': userId,
      'friendId': friendId,
    });
    socket.disconnect();
    _messageStreamController.close();
  }
}
