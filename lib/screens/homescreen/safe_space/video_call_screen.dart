import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:luminarawebsite/screens/homescreen/safe_space/signalling.dart';
import 'package:permission_handler/permission_handler.dart';
class VideoCallScreen extends StatefulWidget {
  final String roomId;

  const VideoCallScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool isMicOn = true;
  bool isCameraOn = true;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStartCall();
  }

  // ✅ Check & Request Permissions
  Future<void> _checkPermissionsAndStartCall() async {
    await _requestPermissions(); // ✅ Ensure permissions are granted
    await _initVideoCall();
  }

  // ✅ Request Camera & Microphone Permissions
  Future<void> _requestPermissions() async {
    final statusCamera = await Permission.camera.request();
    final statusMicrophone = await Permission.microphone.request();

    if (statusCamera.isDenied || statusMicrophone.isDenied) {
      print("🚨 Camera or Microphone permission denied.");
      _showPermissionDeniedDialog();
    }
  }

  // ✅ Show Dialog If Permissions are Denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permissions Required"),
        content: const Text("Camera and Microphone accesshange is required for video calls."),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ✅ Initialize Video Call
  Future<void> _initVideoCall() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      signaling.onAddRemoteStream = (MediaStream stream) {
        print("🎥 Received remote stream: ${stream.id}");
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      };

      // ✅ Open local media (Camera & Mic)
      MediaStream? stream = await signaling.openUserMedia(_localRenderer, _remoteRenderer);

      if (stream != null) {
        print("🎥 Local stream opened successfully: ${stream.id}");

        // 🔥 Ensure local stream is assigned properly
        setState(() {
          _localRenderer.srcObject = stream;
        });
      } else {
        print("❌ Failed to open local stream");
      }

      // ✅ Join the room
      await signaling.joinRoom(widget.roomId, _remoteRenderer);
    } catch (e) {
      print("❌ Error initializing video call: $e");
    }
  }





  @override
  void dispose() {
    signaling.hangUp(_localRenderer);
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }


  // ✅ Toggle Mic
  void _toggleMic() {
    setState(() {
      isMicOn = !isMicOn;
    });
    signaling.localStream?.getAudioTracks().forEach((track) {
      track.enabled = isMicOn;
    });
  }

  // ✅ Toggle Camera
  void _toggleCamera() {
    setState(() {
      isCameraOn = !isCameraOn;
    });
    signaling.localStream?.getVideoTracks().forEach((track) {
      track.enabled = isCameraOn;
    });
  }

  // ✅ End Call
  void _endCall() {
    print("📴 Ending call...");

    // ✅ Hang up properly
    signaling.hangUp(_localRenderer);

    // ✅ Clear video streams before disposing
    setState(() {
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
    });

    // ✅ Dispose renderers safely
    Future.delayed(Duration(milliseconds: 500), () {
      _localRenderer.dispose();
      _remoteRenderer.dispose();
    });

    print("✅ Call Ended, navigating back.");
    Get.back();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Video Call: ${widget.roomId}", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          // ✅ Remote Video (Full Screen)
          Positioned.fill(
            child: RTCVideoView(_remoteRenderer, mirror: false),
          ),
          // ✅ Local Video (Bottom Right)
          Positioned(
            right: 20,
            bottom: 80,
            width: 100,
            height: 150,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)),
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),

          // ✅ Controls (Bottom Center)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mic Toggle Button
                IconButton(
                  icon: Icon(isMicOn ? Icons.mic : Icons.mic_off, color: Colors.white),
                  onPressed: _toggleMic,
                ),
                SizedBox(width: 20),

                // Camera Toggle Button
                IconButton(
                  icon: Icon(isCameraOn ? Icons.videocam : Icons.videocam_off, color: Colors.white),
                  onPressed: _toggleCamera,
                ),
                SizedBox(width: 20),

                // End Call Button
                IconButton(
                  icon: Icon(Icons.call_end, color: Colors.red),
                  onPressed: _endCall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}