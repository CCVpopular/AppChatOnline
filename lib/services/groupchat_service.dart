import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config/config.dart';
import 'SocketManager.dart';

class GroupChatService {
  final String groupId;
  late IO.Socket socket;
  final _messagesStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final String baseUrl = Config.apiBaseUrl;

  GroupChatService(this.groupId) {
    _connectSocket();
    _loadMessages();
  }

  // Kết nối socket
  void _connectSocket() {
    socket = SocketManager(baseUrl).getSocket();

    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('joinGroup', {'groupId': groupId});
    });

    // Lắng nghe tin nhắn mới
    socket.on('receiveGroupMessage', (data) {
      _addMessageToStream(data);
    });
  }

  // Tải tin nhắn từ server
  Future<void> _loadMessages() async {
    final url = Uri.parse('$baseUrl/api/groups/group-messages/$groupId');
    try {
      final response = await http.get(url);
              print(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final messages = data.map((msg) {
          return {
            'sender': msg['sender']['username'],
            'message': msg['message'],
            'timestamp': msg['timestamp'],
          };
        }).toList();


        _messagesStreamController.add(messages);
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  // Thêm tin nhắn mới vào Stream
void _addMessageToStream(Map<String, dynamic> message) async {
  // Lấy danh sách tin nhắn hiện tại
  final currentMessages = await _messagesStreamController.stream.firstWhere((_) => true, orElse: () => []);

  // Kiểm tra nếu StreamController chưa bị đóng
  if (!_messagesStreamController.isClosed) {
    _messagesStreamController.add([...currentMessages, message]);
  } else {
    print('StreamController is closed, cannot add new message');
  }
}


  // Gửi tin nhắn
  void sendMessage(String sender, String message) {
    socket.emit('sendGroupMessage', {
      'groupId': groupId,
      'sender': sender,
      'message': message,
    });
  }

  // Stream để lắng nghe tin nhắn
  Stream<List<Map<String, dynamic>>> get messagesStream =>
      _messagesStreamController.stream;

  // Đóng socket và Stream
void dispose() {
  // Hủy các sự kiện Socket.IO
  socket.off('receiveGroupMessage');
  socket.disconnect();
  socket.close();

  // Đóng StreamController
  if (!_messagesStreamController.isClosed) {
    _messagesStreamController.close();
  }
}

}
