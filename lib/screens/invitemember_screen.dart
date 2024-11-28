import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InviteMemberScreen extends StatefulWidget {
  final String groupId;
  final String userId;

  const InviteMemberScreen({Key? key, required this.groupId, required this.userId}) : super(key: key);

  @override
  _InviteMemberScreenState createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends State<InviteMemberScreen> {
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final url = Uri.parse('http://26.113.132.145:3000/api/friends/invitefriends/${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          friends = data.map((friend) {
            return {
              'id': friend['id'],
              'username': friend['username'],
            };
          }).toList();
          filteredFriends = friends;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (e) {
      print('Error loading friends: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredFriends = friends
          .where((friend) => friend['username'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _addToGroup(String friendId) async {
    final url = Uri.parse('http://26.113.132.145:3000/api/groups/add-member');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'groupId': widget.groupId,
          'userId': friendId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${friendId} to group')),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to add member';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      print('Error adding member to group: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Members'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Friends',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFriends.length,
                    itemBuilder: (context, index) {
                      final friend = filteredFriends[index];
                      return ListTile(
                        title: Text(friend['username']),
                        trailing: ElevatedButton(
                          onPressed: () => _addToGroup(friend['id']),
                          child: Text('Add to Group'),
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
