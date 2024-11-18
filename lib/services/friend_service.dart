import 'dart:convert';
import 'package:http/http.dart' as http;

class FriendService {
  final String baseUrl = 'http://26.113.132.145:3000';

  Future<List<dynamic>> getFriends(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/friends/friends/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch friends');
    }
  }

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

  Future<void> acceptFriend(String friendshipId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/friends/accept-friend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'friendshipId': friendshipId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to accept friend request');
    }
  }
}
