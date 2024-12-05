import 'dart:io';

import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'video_call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String friendId;

  const ChatScreen({Key? key, required this.userId, required this.friendId})
      : super(key: key);

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

      // Gọi hàm sendFile để upload file lên server
      chatService.sendFile(file);
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final file = File(pickedImage.path);
      // Gọi sendFile để upload file
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
    print("Navigating to video call screen..."); // Thêm log
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.transparent, // Màu của AppBar
        elevation: 4.0, // Tạo hiệu ứng đổ bóng cho AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(207, 70, 131, 180), // Màu thứ hai
                Color.fromARGB(41, 130, 190, 197), // Màu đầu tiên
              ],
            ),
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message['sender'] == widget.userId;
                    return Row(
                      mainAxisAlignment: isCurrentUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar cho người gửi khác
                        if (!isCurrentUser)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 4.0),
                            child: CircleAvatar(
                              backgroundColor:
                                  Colors.grey, // Màu xám cho avatar
                              radius: 20, // Kích thước avatar
                              child: Icon(
                                Icons.person, // Biểu tượng người dùng
                                color: Colors.white, // Màu icon
                                size: 20, // Kích thước icon
                              ),
                            ),
                          ),
                        // Bong bóng tin nhắn
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.all(5.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? const Color.fromARGB(145, 130, 190, 197)
                                  : const Color.fromARGB(145, 130, 190, 197),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: message.containsKey('fileUrl')
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (message['message'] != null)
                                        Text(message['message']!),
                                      const SizedBox(height: 8.0),
                                      Image.network(
                                        message['fileUrl']!,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  )
                                : Text(message['message'] ?? ''),
                          ),
                        ),
                        if (isCurrentUser)
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0, right: 8.0),
                            child: CircleAvatar(
                              backgroundColor: Color.fromARGB(
                                  255, 3, 62, 72), // Màu xanh cho avatar
                              radius: 20, // Kích thước avatar
                              child: Icon(
                                Icons.person, // Biểu tượng người dùng
                                color: Colors.white, // Màu icon
                                size: 20, // Kích thước icon
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        ),

        // Khung nhập tin nhắn
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Thanh ngoài của TextField với Gradient
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0), // Padding cho viền
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(
                            176, 70, 131, 180), // Màu thứ hai của gradient
                        Color.fromARGB(
                            39, 130, 190, 197), // Màu đầu tiên của gradient
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(15), // Bo góc cho thanh ngoài
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                      border: InputBorder
                          .none, // Loại bỏ viền mặc định của TextField
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                ),
              ),

              // Nút gửi file với hiệu ứng màu nền
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _selectFile,
                iconSize: 30,
                color: Color.fromARGB(227, 130, 190, 197), // Màu cho icon
              ),

              // Nút gửi tin nhắn với hiệu ứng màu nền
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
                iconSize: 30,
                color: Color.fromARGB(227, 130, 190, 197), // Màu cho icon
              ),

              // Nút gọi video với hiệu ứng màu nền
              IconButton(
                icon: const Icon(Icons.video_call),
                onPressed: _startVideoCall,
                iconSize: 30,
                color: Color.fromARGB(227, 130, 190, 197), // Màu cho icon
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
