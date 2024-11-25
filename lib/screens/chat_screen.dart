import 'dart:io';

import 'package:appchatonline/screens/video_call_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:image_picker/image_picker.dart';
import '../services/chat_service.dart';
import 'package:intl/intl.dart'; // thư viện định dạng thời gian hiện trong phần tin nhắn

class ChatScreen extends StatefulWidget {
  final String userId;
  final String friendId;

  const ChatScreen({super.key, required this.userId, required this.friendId});

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
  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      chatService.sendFile(file);
    }
  }
  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final file = File(pickedImage.path);
    
      chatService.sendFile(file as PlatformFile);
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
    Intl.defaultLocale = 'vi'; // Đặt ngôn ngữ mặc định thành tiếng Việt

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
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
                                ? const Color.fromARGB(255, 12, 181, 164)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: message.containsKey('fileUrl')
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(message['message'] != null)
                                      Text(message['messgae'] !),
                                  const SizedBox(height: 8.0),
                                  // if(message['fileUrl'] != null)
                                    Image.network(
                                      message['fileUrl']!,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),    
                                ],
                              )
                          : Text(message['message'] ?? ''),
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
                    decoration: const InputDecoration(hintText: 'Enter a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _selectFile, 
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
                IconButton(
                  icon: const Icon(Icons.video_call),
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
