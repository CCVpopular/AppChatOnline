import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class FriendService {
  final StreamController<List<dynamic>> _friendsController = StreamController<List<dynamic>>.broadcast();
  Stream<List<dynamic>> get friendsStream => _friendsController.stream;
  IO.Socket? _socket;

  List<dynamic> _friends = [];

  FriendService() {
    _connectToSocket();
  }

  void _connectToSocket() {
    _socket = IO.io('http://26.113.132.145:3000', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket?.on('friendshipUpdated', (data) {
      // Lắng nghe sự kiện cập nhật danh sách bạn bè
      if (data['status'] == 'accepted') {
        _fetchFriends(data);
      }
    });
  }

  Future<void> getFriends(String userId) async {
    try {
      final url = Uri.parse('http://26.113.132.145:3000/api/friends/friends/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _friends = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        _friendsController.add(_friends);
      } else {
        throw Exception('Failed to fetch friends');
      }
    } catch (e) {
      print('Error fetching friends: $e');
      _friendsController.addError(e);
    }
  }

  void _fetchFriends(Map<String, dynamic> data) {
    // Kiểm tra xem bạn bè này đã tồn tại trong danh sách chưa
    final index = _friends.indexWhere((friend) =>
        (friend['requester'] == data['requester'] && friend['receiver'] == data['receiver']) ||
        (friend['requester'] == data['receiver'] && friend['receiver'] == data['requester']));

    if (index != -1) {
      // Nếu tồn tại, cập nhật thông tin
      _friends[index] = data;
    } else {
      // Nếu không, thêm vào danh sách
      _friends.add(data);
    }
    print(_friends);

    // Thông báo cập nhật tới giao diện
    _friendsController.add(List.from(_friends)); // Tạo một danh sách mới để StreamBuilder nhận thay đổi
  }


  void dispose() {
    _socket?.dispose();
    _friendsController.close();
  }
}
