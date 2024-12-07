import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';

class CreateGroupScreen extends StatefulWidget {
  final String userId;
  final String baseUrl = Config.apiBaseUrl;

  const CreateGroupScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  Future<void> _createGroup() async {
    final url = Uri.parse('${widget.baseUrl}/api/groups/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _groupNameController.text,
        'ownerId': widget.userId,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group created successfully!')),
      );
      Navigator.pop(context, true); // Quay lại màn hình trước
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
        backgroundColor: Colors.transparent, // Màu của AppBar
        elevation: 4.0, // Tạo hiệu ứng đổ bóng cho AppBar
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            SizedBox(height: 16),
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
