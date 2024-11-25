import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
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
          'fileUrl': data.containsKey('fileUrl') ? data['fileUrl'] : null, 
          'messageType': data['messageType'] ?? 'text', 
        });
      }
    });

    socket.emit('joinRoom', {'userId': userId, 'friendId': friendId});
  }

  void sendMessage(String message) {
    socket.emit('sendMessage', {
      'sender': userId,
      'receiver': friendId,
      'message': message,
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
    final url = Uri.parse('$baseUrl/api/messages/messages/$userId/$friendId');
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

  //Xử lí upload file, hình ảnh
  Future<void> sendFile(PlatformFile file) async {
    final url = Uri.parse('http://26.24.143.103:3000/api/messages/upload');
    final request = http.MultipartRequest('POST', url);

    request.fields['sender'] = userId;
    request.fields['receiver'] = friendId;
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path!,
      filename: file.name,
  ));

  final response = await request.send();
    if (response.statusCode == 200) {
      print('File uploaded successfully');
    } else {
      print('Failed to upload file: ${response.reasonPhrase}');
    }
  }

  //Xử lí nhận file từ socket
  


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
