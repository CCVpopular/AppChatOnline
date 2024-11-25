import 'package:appchatonline/config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateGroupScreen extends StatefulWidget {
  final String userId;

  const CreateGroupScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<String> _selectedMembers = []; // Store selected members
  final String baseUrl = Config.apiBaseUrl;

  // Mocked list of friends (replace with API fetch)
  final List<Map<String, String>> _friends = [
    {'id': 'user1', 'name': 'John Doe'},
    {'id': 'user2', 'name': 'Jane Smith'},
    {'id': 'user3', 'name': 'Alex Johnson'},
  ];

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty || _selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group name and members are required')),
      );
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/api/groups/create');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'groupName': groupName,
          'creator': widget.userId,
          'members': _selectedMembers,
        }),
      );
      print(url);
      print(response.statusCode);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group created successfully')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create group');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  final friend = _friends[index];
                  final isSelected = _selectedMembers.contains(friend['id']);

                  return ListTile(
                    title: Text(friend['name']!),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.circle_outlined),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedMembers.remove(friend['id']);
                        } else {
                          _selectedMembers.add(friend['id']!);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _createGroup,
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
