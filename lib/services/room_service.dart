// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../config/config.dart';

// class RoomService {
//   final String baseUrl = Config.apiBaseUrl;

//   Future<void> createRoom(String name) async {
//     final url = Uri.parse('$baseUrl/api/rooms/create-room');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'name': name}),
//     );

//     if (response.statusCode != 201) {
//       throw Exception('Failed to create room');
//     }
//   }

//   Future<List<Map<String, dynamic>>> fetchRooms() async {
//     final url = Uri.parse('$baseUrl/api/rooms/rooms');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       return List<Map<String, dynamic>>.from(jsonDecode(response.body));
//     } else {
//       throw Exception('Failed to fetch rooms');
//     }
//   }
// }
