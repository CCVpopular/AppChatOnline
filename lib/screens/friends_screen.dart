import 'package:flutter/material.dart';
import '../services/friend_service.dart';
import 'chat_screen.dart';

class FriendsScreen extends StatefulWidget {
  final String userId;

  const FriendsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<dynamic> friends = [];
  final FriendService friendService = FriendService();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    try {
      final data = await friendService.getFriends(widget.userId);
      setState(() {
        friends = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load friends: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          final friendUsername = friend['requester']['_id'] == widget.userId
              ? friend['receiver']['username']
              : friend['requester']['username'];

          return ListTile(
            title: Text(friendUsername),
            trailing: friend['status'] == 'pending'
                ? ElevatedButton(
                    onPressed: () async {
                      try {
                        await friendService.acceptFriend(friend['_id']);
                        _loadFriends();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to accept request: $e')),
                        );
                      }
                    },
                    child: Text('Accept'),
                  )
                : null,
            onTap: friend['status'] == 'accepted'
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          userId: widget.userId,
                          friendId: friend['requester']['_id'] == widget.userId
                              ? friend['receiver']['_id']
                              : friend['requester']['_id'],
                        ),
                      ),
                    );
                  }
                : null,
          );
        },
      ),
    );
  }
}
