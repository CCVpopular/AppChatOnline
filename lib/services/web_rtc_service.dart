import 'package:appchatonline/services/video_call_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  late RTCPeerConnection _peerConnection;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  final SignalingService signalingService = SignalingService();

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> createPeerConnection(Map<String, List<Map<String, String>>> config) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection =  createPeerConnection(config) as RTCPeerConnection;

    _peerConnection.onIceCandidate = (candidate) {
      // Gửi ICE candidate qua signaling server
      signalingService.sendCandidate(candidate.toMap());
    };

    _peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    // Lấy stream từ media devices
    final localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    localRenderer.srcObject = localStream;

    // Thêm các track vào peer connection
    localStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, localStream);
    });
  }

  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    _peerConnection.close();
  }
}
