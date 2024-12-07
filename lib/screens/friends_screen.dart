import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';
import 'addfriend_screen.dart';
import 'chat_screen.dart';
import 'friendrequests_screen.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart'; // Import provider
import '../theme/theme_notifier.dart'; // Import ThemeNotifier

class FriendsScreen extends StatefulWidget {
  final String userId;

  const FriendsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late FriendService friendService;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    friendService = FriendService();
    friendService.getFriends(widget.userId);
  }

  // @override
  // void dispose() {
  //   friendService.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.transparent, // Màu của AppBar
        elevation: 0, // Tạo hiệu ứng đổ bóng cho AppBar
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white // Viền trắng khi chế độ tối
                  : Colors.black, // Viền đen khi chế độ sáng
              width: 2.0, // Độ dày của viền
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20), // Bo tròn góc dưới bên trái
              bottomRight: Radius.circular(20), // Bo tròn góc dưới bên phải
              topLeft: Radius.circular(38), // Bo tròn góc trên bên phải
              topRight: Radius.circular(38), // Bo tròn góc trên bên phải
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(207, 70, 131, 180), // Màu thứ hai
                Color.fromARGB(41, 132, 181, 187), // Màu đầu tiên
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              friendService.getFriends(widget.userId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFriendScreen(userId: widget.userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FriendRequestsScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: friendService.friendsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load friends'));
          }

          final friends = snapshot.data ?? [];

          if (friends.isEmpty) {
            return const Center(child: Text('No friends yet'));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];

              // Kiểm tra cấu trúc của `friend`
              final friendRequester =
                  friend['requester'] as Map<String, dynamic>? ?? {};
              final friendReceiver =
                  friend['receiver'] as Map<String, dynamic>? ?? {};

              // Lấy tên người bạn gửi và nhận yêu cầu kết bạn
              final friendUsername = friendRequester['_id'] == widget.userId
                  ? (friendReceiver['username'] ?? 'Unknown')
                  : (friendRequester['username'] ?? 'Unknown');

              // Lấy tin nhắn gần nhất và người gửi
              final lastMessage = friend['lastMessage'] ?? 'No message yet';
              final lastSender = friend['lastSender'] ?? 'Unknown sender';

              // Nếu lastSender nằm trong một đối tượng con, hãy điều chỉnh lại truy cập:
              String lastSenderName = lastSender;
              if (lastSender == widget.userId) {
                lastSenderName = 'Bạn'; // Nếu người gửi là người dùng hiện tại
              } else if (lastSender.isNotEmpty) {
                // Nếu lastSender không phải là người dùng hiện tại, xác định tên người gửi
                lastSenderName = friendRequester['_id'] == lastSender
                    ? friendReceiver['username'] ?? 'Unknown'
                    : friendRequester['username'] ?? 'Unknown';
              }

              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // Bo tròn góc
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(10.0),
                      title: Text(
                        friendUsername,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const CircleAvatar(
                        radius: 40,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                        backgroundColor: Color.fromARGB(255, 76, 109, 165),
                      ),
                      subtitle: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // children: [
                        //   // Hiển thị tin nhắn gần đây và người gửi
                        //   Text(
                        //     '$lastSenderName: ${lastMessage.length > 30 ? lastMessage.substring(0, 30) + '...' : lastMessage}',
                        //   ),
                        // ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              userId: widget.userId,
                              friendId: friendRequester['_id'] == widget.userId
                                  ? friendReceiver['_id'] ?? ''
                                  : friendRequester['_id'] ?? '',
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
