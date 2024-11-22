import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddFriendScreen extends StatefulWidget {
  final String userId;

  const AddFriendScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;

  // Hàm tìm kiếm bạn bè
  Future<void> _searchUsers(String username) async {
    if (username.isEmpty) return;
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://26.113.132.145:3000/api/users/search/$username');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          searchResults = data.map((user) => {
                'id': user['_id'],
                'username': user['username'],
              }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to search users');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error searching users: $e');
    }
  }

  // Hàm gửi yêu cầu kết bạn
  Future<void> _sendFriendRequest(String receiverId) async {
    try {
      final url = Uri.parse('http://26.113.132.145:3000/api/friends/add-friend');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requesterId': widget.userId,
          'receiverId': receiverId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request sent!')),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to send friend request';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending friend request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchUsers(_searchController.text),
                ),
              ),
            ),
          ),
          isLoading
              ? Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      return ListTile(
                        title: Text(user['username']),
                        trailing: IconButton(
                          icon: Icon(Icons.person_add),
                          onPressed: () => _sendFriendRequest(user['id']),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
