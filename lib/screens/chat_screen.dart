import 'package:appchatonline/screens/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String friendId;

  const ChatScreen({Key? key, required this.userId, required this.friendId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// Khởi tạo RTCVideoRenderer
  late RTCVideoRenderer localRenderer;
  late RTCVideoRenderer remoteRenderer;

class _ChatScreenState extends State<ChatScreen> {
  late ChatService chatService;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Khởi tạo các đối tượng video renderer
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();

    // Khởi tạo ChatService
    chatService = ChatService(widget.userId, widget.friendId);

    // Tải tin nhắn cũ từ server
    _loadMessages();

    // Lắng nghe tin nhắn mới từ Stream
    chatService.messageStream.listen((message) {
      setState(() {
        messages.add(message);
      });
    });
  }

  Future<void> _loadMessages() async {
    try {
      final oldMessages = await chatService.loadMessages();
      setState(() {
        messages.addAll(oldMessages);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading messages: $e');
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      chatService.sendMessage(_controller.text);
      _controller.clear();
    }
  }

  void _startVideoCall() {
    print("Navigating to video call screen...");  // Thêm log
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          userId: widget.userId,
          friendId: widget.friendId,
          localRenderer: localRenderer,  
          remoteRenderer: remoteRenderer, 
        ),
      ),
    );
  }
  @override
  void dispose() {
    chatService.dispose();
    localRenderer.dispose();  
    remoteRenderer.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
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
                IconButton(
                  icon: Icon(Icons.video_call),
                  onPressed: _startVideoCall,  // Thêm nút gọi video
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
