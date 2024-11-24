import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'package:intl/intl.dart'; // thư viện định dạng thời gian hiện trong phần tin nhắn

class ChatScreen extends StatefulWidget {
  final String userId;
  final String friendId;

  const ChatScreen({Key? key, required this.userId, required this.friendId}) : super(key: key);

  @override
    _ChatScreenState createState() => _ChatScreenState();
  }

class _ChatScreenState extends State<ChatScreen> {
  late ChatService chatService;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

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

  @override
  void dispose() {
    chatService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'vi'; // Đặt ngôn ngữ mặc định thành tiếng Việt

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
                  final String timestampString = message['timestamp']?.toString() ?? ''; // Lấy chuỗi timestamp

                  // Kiểm tra và định dạng timestamp
                  String formattedTime = 'No timestamp'; // Giá trị mặc định nếu không có timestamp
                  if (timestampString.isNotEmpty) {
                    try {
                      // Thử chuyển đổi chuỗi timestamp thành DateTime
                      final DateTime timestamp = DateTime.parse(timestampString);

                      // Định dạng lại timestamp theo định dạng 'Thứ mấy - Giờ AM/PM - Ngày/Tháng/Năm'
                      formattedTime = DateFormat('EEE - hh:mm a - dd/MM/yyyy').format(timestamp);
                    } catch (e) {
                      // Nếu không thể phân tích chuỗi thành DateTime, in lỗi
                      print('Error parsing timestamp: $e');
                      formattedTime = 'Invalid time format'; // Hiển thị thông báo lỗi
                    }
                  }
                  print('Timestamp string: $timestampString'); // Kiểm tra giá trị của timestampString
                  print(formattedTime); // In kết quả thời gian đã được định dạng
                  return Column(
                    crossAxisAlignment: message['sender'] == widget.userId
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Align(
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
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: message['sender'] == widget.userId
                                  ? Radius.circular(10)
                                  : Radius.zero,
                              bottomRight: message['sender'] == widget.userId
                                  ? Radius.zero
                                  : Radius.circular(10),
                            ),
                            border: Border.all(
                              color: message['sender'] == widget.userId
                                  ? const Color.fromARGB(255, 12, 181, 164)
                                  : Colors.grey[500]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 0,
                                offset: Offset(5, 9),
                              ),
                            ],
                          ),
                          child: Text(
                            message['message']!,
                            style: TextStyle(
                              color: message['sender'] == widget.userId
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Text(
                          formattedTime,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
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
