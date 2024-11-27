import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FriendRequestsScreen extends StatefulWidget {
  final String userId;

  const FriendRequestsScreen({super.key, required this.userId});

  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<Map<String, dynamic>> friendRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    try {
      final url = Uri.parse('http://26.113.132.145:3000/api/friends/friend-requests/${widget.userId}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          friendRequests = data.map((request) {
            return {
              'id': request['_id'], // ID của lời mời kết bạn
              'requesterId': request['requester']['_id'], // ID của người gửi
              'username': request['requester']['username'], // Tên người gửi
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load friend requests');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading friend requests: $e');
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      final url = Uri.parse('http://26.113.132.145:3000/api/friends/accept-friend');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'friendshipId': requestId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request accepted!')),
        );
        setState(() {
          friendRequests.removeWhere((req) => req['id'] == requestId);
        });
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to accept friend request';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting friend request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friendRequests.isEmpty
              ? const Center(child: Text('No friend requests'))
              : ListView.builder(
                  itemCount: friendRequests.length,
                  itemBuilder: (context, index) {
                    final request = friendRequests[index];
                    return ListTile(
                      title: Text(request['username']),
                      trailing: ElevatedButton(
                        onPressed: () => _acceptRequest(request['id']),
                        child: const Text('Accept'),
                      ),
                    );
                  },
                ),
    );
  }
}
