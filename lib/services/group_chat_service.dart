import 'dart:async';
import 'package:appchatonline/services/SocketManager.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config/config.dart';

class GroupChatService {
  final String groupId;
  final String userId;
  late IO.Socket socket;

  // Stream to listen to messages
  final _messageStreamController = StreamController<Map<String, String>>.broadcast();

  GroupChatService({required this.groupId, required this.userId}) {
    socket = SocketManager(Config.apiBaseUrl).getSocket();
    _initializeSocket();
  }

  void _initializeSocket() {
    
    socket.onConnect((_) {
      print('Connected to server for group chat');
      _joinGroup();
    });

    socket.on('receiveGroupMessage', (data) {
      _messageStreamController.add({
        'sender': data['sender'],
        'message': data['message'],
      });
    });

    socket.on('userJoined', (data) {
      _messageStreamController.add({'sender': 'System', 'message': data});
    });

    socket.on('userLeft', (data) {
      _messageStreamController.add({'sender': 'System', 'message': data});
    });

    socket.onDisconnect((_) => print('Disconnected from group chat server'));
  }

  void _joinGroup() {
    socket.emit('joinGroup', {'groupId': groupId, 'userId': userId});
  }

  void sendMessage(String message) {
    socket.emit('sendGroupMessage', {
      'groupId': groupId,
      'sender': userId,
      'message': message,
    });
    _messageStreamController.add({'sender': userId, 'message': message});
  }

  Stream<Map<String, String>> get messageStream => _messageStreamController.stream;

  void leaveGroup() {
    socket.emit('leaveGroup', {'groupId': groupId, 'userId': userId});
  }

  void dispose() {
    leaveGroup();
    _messageStreamController.close();
    socket.dispose();
  }
}
