import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../screens/homescreen/call_ended_screen.dart';
import '../test/test/services/webrtc_service.dart';
import '../widgets/navigation_bar.dart'; // Adjust the import path as needed

class CallController {
  final WebRtcService fbCallService;
  final Function(String) onRoomIdGenerated;
  final Function() onCallEnded;
  final Function() onConnectionEstablished;
  final Function() onStateChanged; // Notify UI when state changes

  RTCPeerConnection? peerConnection;
  final RTCVideoRenderer localVideo = RTCVideoRenderer();
  final RTCVideoRenderer remoteVideo = RTCVideoRenderer();
  MediaStream? localStream;

  bool isAudioOn = true;
  bool isVideoOn = true;
  bool isFrontCameraSelected = true;
  bool _isNavigating = false; // ✅ Added flag to prevent multiple exits

  CallController({
    required this.fbCallService,
    required this.onRoomIdGenerated,
    required this.onCallEnded,
    required this.onConnectionEstablished,
    required this.onStateChanged, // Pass state change callback
  });

  Future<void> init(String? roomId) async {
    try {
      await remoteVideo.initialize();

      // Set up remote stream handling
      peerConnection?.onTrack = (event) {
        if (event.track.kind == 'video') {
          remoteVideo.srcObject = event.streams.first;
          onConnectionEstablished();
        }
      };

      if (roomId == null) {
        // Create a new call
        String newRoomId = await fbCallService.call();
        onRoomIdGenerated(newRoomId);
        iceStatusListen();
      } else {
        // Join an existing call
        await fbCallService.answer(roomId: roomId);
        iceStatusListen();
      }
    } catch (e) {
      debugPrint("❌ CallController.init Error: $e");
    }
  }


  Future<void> openCamera() async {
    await localVideo.initialize();
    peerConnection = await fbCallService.createPeer();

    final Map<String, dynamic> mediaConstraints = {
      'audio': isAudioOn,
      'video': isVideoOn,
    };

    // Get user media (camera and microphone)
    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    // Add tracks to the peer connection
    localStream!.getTracks().forEach((track) async {
      await peerConnection?.addTrack(track, localStream!);
    });

    // Set the local video source
    localVideo.srcObject = localStream;
  }

  void iceStatusListen() {
    peerConnection?.onIceConnectionState = (iceConnectionState) async {
      if (iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        debugPrint("✅ WebRTC Connection Established");

        // ✅ Update UI State Immediately When Connection is Ready
        onConnectionEstablished();
      }

      if (iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
          iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        debugPrint("❌ WebRTC Disconnected or Failed");
        onCallEnded();
      }
    };
  }


  void toggleMic() {
    final audioTrack = localStream?.getAudioTracks().first;
    if (audioTrack != null) {
      audioTrack.enabled = !audioTrack.enabled;
      debugPrint("🎙️ Mic is now ${audioTrack.enabled ? 'ON' : 'OFF'}");
    } else {
      debugPrint("❌ No audio track found");
    }
  }
  Future<void> toggleSpeaker(bool enableSpeaker) async {
    try {
      await Helper.setSpeakerphoneOn(enableSpeaker);
      debugPrint("🔊 Speakerphone ${enableSpeaker ? 'ON' : 'OFF'}");
    } catch (e) {
      debugPrint("❌ Error toggling speaker: $e");
    }
  }


  void toggleCamera() {
    isVideoOn = !isVideoOn;
    localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
  }

  void switchCamera() {
    isFrontCameraSelected = !isFrontCameraSelected;
    localStream?.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
  }

  /// ✅ Enhanced `dispose()` for Clean Exit and Navigation
  Future<void> dispose({
    required BuildContext context,
    String? userId,
    String? sessionType,
  }) async {
    if (_isNavigating) return; // ✅ Prevent multiple exits
    _isNavigating = true;

    debugPrint("🔥 Leaving Call and Cleaning Resources...");

    try {
      // ✅ Stop Media Tracks (Camera + Mic)
      localStream?.getTracks().forEach((track) => track.stop());

      // ✅ Clean Video Renders
          await localVideo.dispose();
          await remoteVideo.dispose();
      localStream?.dispose();
      peerConnection?.dispose();

      // ✅ Firestore Status Change
      if (userId != null && sessionType != null) {
        await FirebaseFirestore.instance
            .collection("safe_talk/${sessionType.toLowerCase()}/queue")
            .doc(userId)
            .set({
          'status': 'finished'
        }, SetOptions(merge: true));
      }

      // ✅ Navigate Back Using `Navigator.pushReplacement`
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CallEndedScreen(),
          ),
        );
        debugPrint("✅ Successfully Navigated Back!");
      } else {
        debugPrint("❗ Unable to Navigate Back. Context is Unmounted.");
      }
    } catch (e) {
      debugPrint("❌ Error during Leave Call Process: $e");
    }

    _isNavigating = false;
  }
}
