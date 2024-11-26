import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String userId;
  final String friendId;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  const VideoCallScreen({
    super.key,
    required this.userId,
    required this.friendId,
    required this.localRenderer,
    required this.remoteRenderer,
  });

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMicrophoneMuted = false;
  bool isCameraOff = false;
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    widget.localRenderer.initialize();
    widget.remoteRenderer.initialize();
    requestPermissions();
    _initiateCall();
  }

  // Yêu cầu quyền camera và microphone
  void requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      print("Permissions granted");
    } else {
      print("Permissions denied");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Camera and microphone permissions are required.")),
      );
      if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  void _initiateCall() async {
    final mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user', // Sử dụng camera trước
      },
    };

    try {
      MediaStream localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localStream = localStream; // Lưu trữ stream cục bộ
      widget.localRenderer.srcObject = localStream;
      print("Local stream initialized: ${localStream.id}");
    } catch (e) {
      print("Error initializing camera: $e");
    }

    // Thực hiện các kết nối WebRTC khác
  }

  @override
  void dispose() {
    widget.localRenderer.dispose();
    widget.remoteRenderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        backgroundColor: Colors.transparent,
        elevation: 4.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(207, 70, 131, 180),
                Color.fromARGB(41, 130, 190, 197),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isMicrophoneMuted ? Icons.mic_off : Icons.mic),
            onPressed: _toggleMicrophone,
          ),
          IconButton(
            icon: Icon(isCameraOff ? Icons.videocam_off : Icons.videocam),
            onPressed: _toggleCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Hiển thị video của người khác (remote video)
          Positioned.fill(
            child: widget.remoteRenderer.srcObject != null
                ? RTCVideoView(widget.remoteRenderer)
                : Container(color: Colors.black),
          ),
          // Hiển thị video của bản thân (local video) với khung hình đẹp hơn
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), // Bo tròn góc
                border: Border.all(color: Colors.white, width: 2), // Viền trắng
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4), // Đổ bóng nhẹ
                  ),
                ],
              ),
              child: isCameraOff
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16), // Cắt góc video
                      child: RTCVideoView(widget.localRenderer, mirror: true),
                    ),
            ),
          ),
          _buildControlPanel(),
        ],
      ),
    );
  }

  // Nút điều khiển micro
  void _toggleMicrophone() {
    setState(() {
      isMicrophoneMuted = !isMicrophoneMuted;
    });
    if (_localStream != null) {
      var audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !isMicrophoneMuted;
    }
  }

  // Nút điều khiển camera
  void _toggleCamera() {
    setState(() {
      isCameraOff = !isCameraOff;
    });
    if (_localStream != null) {
      var videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !isCameraOff;
    }
  }

  // Tạo điều khiển thêm
  Widget _buildControlPanel() {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.call_end),
            color: Colors.red,
            onPressed: _endCall,
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _switchCamera,
          ),
        ],
      ),
    );
  }

  // Kết thúc cuộc gọi
  void _endCall() {
    _localStream?.dispose();
    Navigator.pop(context);
  }

  // Chuyển đổi camera (nếu hỗ trợ)
  void _switchCamera() async {
    if (_localStream != null) {
      var videoTrack = _localStream!.getVideoTracks().first;
      if (videoTrack != null) {
        try {
          await videoTrack.switchCamera();
          print("Camera switched successfully");
        } catch (e) {
          print("Error switching camera: $e");
        }
      }
    }
  }
}
