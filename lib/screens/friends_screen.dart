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
  final FriendService friendService = FriendService();

  @override
  void initState() {
    super.initState();
    // Tải danh sách bạn bè ban đầu
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
              friendService
                  .getFriends(widget.userId); // Tải lại danh sách bạn bè
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

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final friendUsername = friend['requester']['_id'] == widget.userId
                  ? friend['receiver']['username']
                  : friend['requester']['username'];

              return ListTile(
                title: Text(friendUsername),
                onTap: friend['status'] == 'accepted'
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              userId: widget.userId,
                              friendId:
                                  friend['requester']['_id'] == widget.userId
                                      ? friend['receiver']['_id']
                                      : friend['requester']['_id'],
                            ),
                          ),
                        );
                      }
                    : null,
              );
            },
          );
        },
      ),

    );
  }
}
