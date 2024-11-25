import 'package:appchatonline/screens/creategroup_screen.dart';
import 'package:flutter/material.dart';
import 'group_chat_screen.dart';

class GroupListScreen extends StatelessWidget {
  final String userId;

  GroupListScreen({Key? key, required this.userId}) : super(key: key);

  final List<Map<String, String>> groups = [
    {'id': 'general', 'name': 'General Group'},
    {'id': 'sports', 'name': 'Sports Group'},
    {'id': 'tech', 'name': 'Tech Group'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateGroupScreen(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return ListTile(
            title: Text(group['name']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChatScreen(
                    groupId: group['id']!,
                    userId: userId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
