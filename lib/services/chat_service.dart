import 'dart:async';
import 'dart:convert';
import 'package:appchatonline/services/SocketManager.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config/config.dart';

class ChatService {
  late IO.Socket socket;
  final _messageStreamController = StreamController<Map<String, String>>.broadcast();
  final String userId;
  final String friendId;

  final String baseUrl = Config.apiBaseUrl;

ChatService(this.userId, this.friendId) {
    socket = SocketManager(Config.apiBaseUrl).getSocket();
    _connectSocket();
  }

  void _connectSocket() {
    socket.on('receiveMessage', (data) {
      if (data['sender'] != userId) {
        _messageStreamController.add({
          'sender': data['sender'],
          'message': data['message'],
        });
      }
    });

    socket.emit('joinRoom', {'userId': userId, 'friendId': friendId});
  }

  void sendMessage(String message) {
    final createdAt = DateTime.now().toIso8601String();  // Lấy thời gian hiện tại

    socket.emit('sendMessage', {
      'sender': userId,
      'receiver': friendId,
      'message': message,
      'createdAt': createdAt,  // Thêm timestamp vào dữ liệu gửi
    });
    _messageStreamController.add({'sender': userId, 'message': message});
  }

  // Stream<Map<String, String>> get messageStream => _messageStreamController.stream;

  void dispose() {
    socket.emit('leaveRoom', {'userId': userId, 'friendId': friendId});
    _messageStreamController.close();
  }

  // Hàm lấy tin nhắn cũ
  Future<List<Map<String, String>>> loadMessages() async {
    final url = Uri.parse('${baseUrl}/api/messages/messages/$userId/$friendId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((msg) {
          return {
            'sender': msg['sender'].toString(),
            'message': msg['message'].toString(),
            'createdAt': msg['createdAt'].toString(),  // Thêm timestamp vào tin nhắn cũ
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

  // // Đóng Stream và Socket
  // void dispose() {
  //   socket.emit('leaveRoom', {
  //     'userId': userId,
  //     'friendId': friendId,
  //   });
  //   socket.disconnect();
  //   _messageStreamController.close();
  // }
}