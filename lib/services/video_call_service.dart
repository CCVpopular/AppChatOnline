import 'package:socket_io_client/socket_io_client.dart' as IO;

class SignalingService {
  late IO.Socket _socket;

  void connect() {
    _socket = IO.io('http://localhost:3000', IO.OptionBuilder()
        .setTransports(['websocket'])
        .build());

    _socket.on('offer', (data) {
      // Xử lý khi nhận được offer
    });

    _socket.on('answer', (data) {
      // Xử lý khi nhận được answer
    });

    _socket.on('candidate', (data) {
      // Xử lý khi nhận được ICE candidate
    });
  }

  void sendOffer(Map<String, dynamic> offer) {
    _socket.emit('offer', offer);
  }

  void sendAnswer(Map<String, dynamic> answer) {
    _socket.emit('answer', answer);
  }

  void sendCandidate(Map<String, dynamic> candidate) {
    _socket.emit('candidate', candidate);
  }

  void disconnect() {
    _socket.disconnect();
  }
}
