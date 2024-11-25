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

  @override
  void initState() {
    super.initState();
    widget.localRenderer.initialize();
    widget.remoteRenderer.initialize();
    requestPermissions(); // Yêu cầu quyền khi màn hình khởi tạo
    _initiateCall();
  }

  // Yêu cầu quyền camera và microphone
  void requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      // Nếu quyền đã được cấp, bạn có thể tiếp tục gọi WebRTC
      print("Permissions granted");
    } else {
      // Xử lý trường hợp quyền bị từ chối
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
    await widget.localRenderer.initialize(); // Khởi tạo renderer trước
    await widget.remoteRenderer.initialize(); // Khởi tạo renderer trước
    final mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user', // Sử dụng camera trước
      },
    };

    try {
      MediaStream localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      widget.localRenderer.srcObject = localStream;
      print("Local stream initialized: ${localStream.id}");
    } catch (e) {
      print("Error initializing camera: $e");
    }

    // Thực hiện các kết nối WebRTC khác như kết nối với friendId để gửi stream video đi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        backgroundColor: Colors.transparent,   // Màu của AppBar
        elevation: 4.0, // Tạo hiệu ứng đổ bóng cho AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(207, 70, 131, 180),  // Màu thứ hai
                Color.fromARGB(41, 130, 190, 197), // Màu đầu tiên
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
          Positioned.fill(
            child: widget.remoteRenderer.srcObject != null
                ? RTCVideoView(widget.remoteRenderer)
                : Container(
                    color: Colors
                        .black), // Hiển thị màn hình đen nếu chưa có dữ liệu
          ),
          Positioned(
            bottom: 20,
            right: 20,
            width: 100,
            height: 150,
            child: RTCVideoView(widget.localRenderer,
                mirror: true), // Video của người dùng
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
    // Thực hiện tắt/bật micro nếu cần
  }

  // Nút điều khiển camera
  void _toggleCamera() {
    setState(() {
      isCameraOff = !isCameraOff;
    });
    // Thực hiện tắt/bật camera nếu cần
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
    Navigator.pop(context);
  }

  // Chuyển đổi camera (nếu hỗ trợ)
  void _switchCamera() {
    // Sử dụng API WebRTC để chuyển đổi camera nếu cần
  }
}
