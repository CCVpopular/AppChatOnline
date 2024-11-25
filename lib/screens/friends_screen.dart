import 'package:appchatonline/screens/group_list_screen.dart';
import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import 'addfriend_screen.dart';
import 'chat_screen.dart';
import 'friendrequests_screen.dart';

class FriendsScreen extends StatefulWidget {
  final String userId;

  const FriendsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late FriendService friendService;

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
        title: Text('Friends'),
        actions: [
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
                  builder: (context) => GroupListScreen(userId: widget.userId),
                ),
              );
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
    final friendRequester = friend['requester'] as Map<String, dynamic>? ?? {};
    final friendReceiver = friend['receiver'] as Map<String, dynamic>? ?? {};
    final friendUsername = friendRequester['_id'] == widget.userId
        ? (friendReceiver['username'] ?? 'Unknown')
        : (friendRequester['username'] ?? 'Unknown');

    return ListTile(
      title: Text(friendUsername),
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
    );
  },
);



        },
      ),

    );
  }
}
