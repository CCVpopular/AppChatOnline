import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import 'addfriend_screen.dart';
import 'chat_screen.dart';
import 'friendrequests_screen.dart';
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
  double _circleSize = 50; // Kích thước ban đầu của vòng tròn hiệu ứng
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    friendService = FriendService();
    friendService.getFriends(widget.userId);
  }

  @override
  void dispose() {
    friendService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
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
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeNotifier>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // Tạo hành động chuyển đổi theme
              final themeNotifier = context.read<ThemeNotifier>();
              final currentTheme = themeNotifier.themeMode;
              themeNotifier.setThemeMode(
                currentTheme == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              friendService.getFriends(widget.userId);
            },
          ),
          IconButton(
            icon: Icon(Icons.person_add),
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
            icon: Icon(Icons.group),
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
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load friends'));
          }

          final friends = snapshot.data ?? [];

          if (friends.isEmpty) {
            return Center(child: Text('No friends yet'));
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
              final friendUsername = friendRequester['_id'] == widget.userId
                  ? (friendReceiver['username'] ?? 'Unknown')
                  : (friendRequester['username'] ?? 'Unknown');

              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // Bo tròn góc
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(
                          207, 70, 131, 180), // Màu thứ hai của gradient
                      Color.fromARGB(129, 130, 190, 197), // Màu đầu tiên
                    ],
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(
                      10.0), // Padding cho nội dung ListTile
                  title: Text(
                    friendUsername,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0,
                          0), // Màu chữ trắng để nổi bật trên nền gradient
                    ),
                  ),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 30, // Kích thước của avatar
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green, // Chấm xanh
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
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
              );
            },
          );
        },
      ),
    );
  }
}
