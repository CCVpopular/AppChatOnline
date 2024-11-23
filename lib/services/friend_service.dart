import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FriendService {
  final String baseUrl = 'http://26.113.132.145:3000';

  // StreamController để quản lý danh sách bạn bè
  final _friendsStreamController = StreamController<List<dynamic>>.broadcast();

  // Getter để cung cấp Stream cho các widget
  Stream<List<dynamic>> get friendsStream => _friendsStreamController.stream;

  // Hàm tải danh sách bạn bè
  Future<void> getFriends(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/friends/friends/$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> friends = jsonDecode(response.body);
      _friendsStreamController.add(friends); // Phát danh sách bạn bè qua Stream
    } else {
      throw Exception('Failed to fetch friends');
    }
  }

  // Hàm gửi yêu cầu kết bạn
  Future<void> addFriend(String requesterId, String receiverId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/friends/add-friend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'requesterId': requesterId, 'receiverId': receiverId}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to send friend request');
    }
  }

  // Hàm chấp nhận lời mời kết bạn
  Future<void> acceptFriend(String friendshipId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/friends/accept-friend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'friendshipId': friendshipId}),
    );
    if (response.statusCode == 200) {
      // Sau khi chấp nhận, tải lại danh sách bạn bè
      await getFriends(userId);
    } else {
      throw Exception('Failed to accept friend request');
    }
  }

  // Đóng StreamController khi không còn sử dụng
  void dispose() {
    _friendsStreamController.close();
  }
}
