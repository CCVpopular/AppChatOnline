import 'package:appchatonline/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String userId;
  final String friendId;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  const VideoCallScreen({
    Key? key,
    required this.userId,
    required this.friendId,
    required this.localRenderer,
    required this.remoteRenderer, 
  }) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool isMicrophoneMuted = false;
  bool isCameraOff = false;

  @override
  void initState() {
    super.initState();
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
    }
  }

  // Khởi tạo cuộc gọi và bắt đầu stream từ camera
  void _initiateCall() async {
    await widget.localRenderer.initialize();  // Khởi tạo renderer trước
    await widget.remoteRenderer.initialize();  // Khởi tạo renderer trước
    final mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',  // Dùng camera trước
      },
    };
    

    MediaStream localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    if (localStream != null) {
      print('Stream đã được lấy thành công');
      localRenderer.srcObject = localStream;
    }else {
      print('Không thể lấy stream từ camera');
    }

    
    widget.localRenderer.srcObject = localStream;
    
    // Thực hiện các kết nối WebRTC khác như kết nối với friendId để gửi stream video đi
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
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
            child: RTCVideoView(widget.remoteRenderer),  // Video của bạn bè
          ),
          Positioned(
            bottom: 20,
            right: 20,
            width: 100,
            height: 150,
            child: RTCVideoView(widget.localRenderer, mirror: true),  // Video của người dùng
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
    // Thực hiện tắt/mở micro
    final audioTrack = widget.localRenderer.srcObject?.getTracks().firstWhere((track) => track.kind == 'audio');
    if (audioTrack != null) {
      audioTrack.enabled = !isMicrophoneMuted;
    }
  }

  // Nút điều khiển camera
  void _toggleCamera() {
    setState(() {
      isCameraOff = !isCameraOff;
    });
    // Thực hiện tắt/mở camera
    final videoTrack = widget.localRenderer.srcObject?.getTracks().firstWhere((track) => track.kind == 'video');
    if (videoTrack != null) {
      videoTrack.enabled = !isCameraOff;
    }else {
    print("Không tìm thấy track video");
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
            icon: Icon(Icons.call_end),
            color: Colors.red,
            onPressed: _endCall,
          ),
          IconButton(
            icon: Icon(Icons.switch_camera),
            onPressed: _switchCamera,
          ),
        ],
      ),
    );
  }

  // Kết thúc cuộc gọi
  void _endCall() {
    widget.localRenderer.srcObject?.getTracks().forEach((track) => track.stop());  // Dừng tất cả các track
    widget.remoteRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    Navigator.pop(context);
  }

  // Chuyển đổi camera (nếu hỗ trợ)
  void _switchCamera() {
    final videoTrack = widget.localRenderer.srcObject?.getTracks().firstWhere((track) => track.kind == 'video');
    if (videoTrack != null) {
      // Chuyển đổi camera (dùng phương thức switchCamera của WebRTC)
      videoTrack.switchCamera();
    }
  }
}
