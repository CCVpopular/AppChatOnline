import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/config.dart';
import 'SocketManager.dart';

class GroupChatService {
  final String groupId;
  late IO.Socket socket;
  final _messagesgroupStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final String baseUrl = Config.apiBaseUrl;

  GroupChatService(this.groupId) {
    _connectSocket();
    _loadMessages();
  }

  // Kết nối socket
  void _connectSocket() {
    socket = SocketManager(baseUrl).getSocket();

    print('Connected to chat group');

    // Lắng nghe tin nhắn mới
    socket.on('receiveGroupMessage', (data) {
      // _addMessageToStream(data);
      _loadMessages();
    });
    socket.emit('joinGroup', {'groupId': groupId});
  }

  // Tải tin nhắn từ server
  Future<void> _loadMessages() async {
    final url = Uri.parse('$baseUrl/api/groups/group-messages/$groupId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final messages = data.map((msg) {
          return {
            'sender': msg['sender']['username'],
            'message': msg['message'],
            'timestamp': msg['timestamp'],
          };
        }).toList();

        if (!_messagesgroupStreamController.isClosed) {
          _messagesgroupStreamController.add(messages);
        }
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  void _addMessageToStream(Map<String, dynamic> message) async {
    final currentMessages = await _messagesgroupStreamController.stream
        .firstWhere((_) => true, orElse: () => []);

    if (!_messagesgroupStreamController.isClosed) {
      _messagesgroupStreamController.add([...currentMessages, message]);
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
  Stream<List<Map<String, dynamic>>> get messagesgruopStream =>
      _messagesgroupStreamController.stream;

  // Đóng socket và Stream
  void dispose() {
    socket.emit('leaveGroup', {'groupId': groupId});
    socket.off('receiveGroupMessage');
    socket.disconnect();
    if (!_messagesgroupStreamController.isClosed) {
      _messagesgroupStreamController.close();
    }
  }
}
