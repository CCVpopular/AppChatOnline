import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String userId;
  final String friendId;

  const ChatScreen({Key? key, required this.userId, required this.friendId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Tải tin nhắn cũ khi mở chat
    _connectSocket();
  }

  // Hàm tải tin nhắn cũ từ server
  Future<void> _loadMessages() async {
    final url = Uri.parse('http://26.113.132.145:3000/api/messages/messages/${widget.userId}/${widget.friendId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          messages.addAll(data.map((msg) {
            return {
              'sender': msg['sender'] as String,
              'message': msg['message'] as String,
            };
          }).toList());

        });
      } else {
        print('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

void _connectSocket() {
  socket = IO.io(
    'http://26.113.132.145:3000',
    IO.OptionBuilder().setTransports(['websocket']).build(),
  );

  socket.onConnect((_) {
    print('Connected to server');

    // Tham gia phòng chat
    socket.emit('joinRoom', {
      'userId': widget.userId,
      'friendId': widget.friendId,
    });
  });

  // Xóa các sự kiện cũ trước khi đăng ký mới
  socket.off('receiveMessage');
  
  // Đăng ký sự kiện nhận tin nhắn
  socket.on('receiveMessage', (data) {
    if (data['sender'] != widget.userId) {
      setState(() {
        messages.add({
          'sender': data['sender'],
          'message': data['message'],
        });
      });
    }
  });
}



  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      socket.emit('sendMessage', {
        'sender': widget.userId,
        'receiver': widget.friendId,
        'message': _controller.text,
      });
      setState(() {
        messages.add({'sender': widget.userId, 'message': _controller.text});
      });
      _controller.clear();
    }
  }

@override
void dispose() {
  // Gửi sự kiện rời khỏi phòng
  socket.emit('leaveRoom', {
    'userId': widget.userId,
    'friendId': widget.friendId,
  });

  // Ngắt kết nối socket
  socket.disconnect();
  socket.close();

  super.dispose();
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['sender'] == widget.userId
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message['sender'] == widget.userId
                          ? Colors.blue[200]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['message']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
