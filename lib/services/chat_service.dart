import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appchatonline/services/SocketManager.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../config/config.dart';

class ChatService {
  late IO.Socket socket;
  final _messageStreamController =
      StreamController<Map<String, String>>.broadcast();
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
    socket.emit('sendMessage', {
      'sender': userId,
      'receiver': friendId,
      'message': message,
    });
    _messageStreamController.add({'sender': userId, 'message': message});
  }

  // Stream để lắng nghe tin nhắn
  Stream<Map<String, String>> get messageStream =>
      _messageStreamController.stream;

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
          };
        }).toList();
      } else {
        throw Exception('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading messages: $e');
    }
  }

 // Hàm để lấy đường dẫn tệp thực tế từ URI
Future<String> getFilePathFromUri(Uri uri) async {
  final file = File(uri.path!); // Tạo đối tượng File từ URI
  if (await file.exists()) {
    final directory = await getTemporaryDirectory(); // Lấy thư mục tạm
    final tempFile = File('${directory.path}/${file.uri.pathSegments.last}');
    // Sao chép file vào thư mục tạm và trả về đường dẫn mới
    await file.copy(tempFile.path);
    return tempFile.path;
  } else {
    throw Exception("File does not exist at the given URI");
  }
}

  // Xử lý upload file
  Future<void> sendFile(PlatformFile file) async {
    final url = Uri.parse('${baseUrl}/api/messages/upload');
    final request = http.MultipartRequest('POST', url);

    request.fields['sender'] = userId;
    request.fields['receiver'] = friendId;

    // Lấy đường dẫn file thực tế từ URI
    final filePath = await getFilePathFromUri(Uri.parse(file.path!));
    print('File path: $filePath');
    
      

    // Gửi file lên server
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath, // Sử dụng đường dẫn file đã chuyển đổi
      filename: file.name,
    ));

    final response = await request.send();
    if (response.statusCode == 200) {
      print('File uploaded successfully');
    } else {
      print(
          'Failed to upload file: ${response.statusCode}, ${response.reasonPhrase}');
    }
  }
}
