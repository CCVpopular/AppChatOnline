import 'package:flutter/material.dart';
import '../services/groups_service.dart';
import 'creategroup_screen.dart';
import 'groupchat_screen.dart';

class GroupsScreen extends StatefulWidget {
  final String userId;

  const GroupsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  late GroupsService groupsService;

  @override
  void initState() {
    super.initState();
    groupsService = GroupsService(widget.userId);
  }

  @override
  void dispose() {
    groupsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateGroupScreen(userId: widget.userId),
                ),
              ).then((result) {
                if (result == true) {
                  groupsService.refreshGroups(); // Gọi hàm làm mới danh sách nhóm
                }
              });
            },
            child: const Text('Create Group'),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: groupsService.groupsStream,  
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading groups'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No groups found'));
          }

          final groups = snapshot.data!;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // Bo tròn góc 
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(10.0),
                      title: Text(
                        group['name'] ?? 'Unnamed Group',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const CircleAvatar(
                        radius: 40,
                        child: Icon(
                          Icons.group,
                          size: 40,
                          color: Colors.white,
                        ),
                        backgroundColor: Color.fromARGB(255, 76, 109, 165),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Owner: ${group['owner'] ?? 'Unknown'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupChatScreen(
                              groupId: group['id'],
                              userId: widget.userId,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
