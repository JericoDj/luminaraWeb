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
  final Function() onStateChanged;

  RTCPeerConnection? peerConnection;
  final RTCVideoRenderer localVideo = RTCVideoRenderer();
  final RTCVideoRenderer remoteVideo = RTCVideoRenderer();
  MediaStream? localStream;

  bool isAudioOn = true;
  bool isVideoOn = true;
  bool isFrontCameraSelected = true;
  bool _isNavigating = false;

  CallController({
    required this.fbCallService,
    required this.onRoomIdGenerated,
    required this.onCallEnded,
    required this.onConnectionEstablished,
    required this.onStateChanged,
  });

  Future<void> init(String? roomId) async {
    try {
      await remoteVideo.initialize();
      remoteVideo.muted = false; // ✅ Ensure audio is not muted
      await remoteVideo.audioOutput('default'); // or the actual device ID if known


      peerConnection?.onTrack = (event) {
        final kind = event.track.kind;
        debugPrint("📥 Track received: $kind");

        if (event.streams.isNotEmpty) {
          remoteVideo.srcObject = event.streams.first;
          final audioTracks = event.streams.first.getAudioTracks();
          debugPrint("🔊 Remote audio tracks: ${audioTracks.length}");
        } else {
          debugPrint("⚠️ No streams attached to remote track.");
        }

        onConnectionEstablished();
      };

      if (roomId == null) {
        String newRoomId = await fbCallService.call();
        onRoomIdGenerated(newRoomId);
        iceStatusListen();
      } else {
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

    final mediaConstraints = {
      'audio': isAudioOn,
      'video': isVideoOn,
    };

    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    for (var track in localStream!.getTracks()) {
      await peerConnection?.addTrack(track, localStream!);
    }

    localVideo.srcObject = localStream;
  }

  void iceStatusListen() {
    peerConnection?.onIceConnectionState = (state) async {
      debugPrint("ICE state: $state");

      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        debugPrint("✅ WebRTC Connected");
        onConnectionEstablished();
      }

      if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
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

  Future<void> dispose({
    required BuildContext context,
    String? userId,
    String? sessionType,
  }) async {
    if (_isNavigating) return;
    _isNavigating = true;

    debugPrint("🔥 Leaving Call and Cleaning Resources...");

    try {
      localStream?.getTracks().forEach((track) => track.stop());
      await localVideo.dispose();
      await remoteVideo.dispose();
      localStream?.dispose();
      peerConnection?.dispose();

      if (userId != null && sessionType != null) {
        await FirebaseFirestore.instance
            .collection("safe_talk/${sessionType.toLowerCase()}/queue")
            .doc(userId)
            .set({'status': 'finished'}, SetOptions(merge: true));
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CallEndedScreen()),
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
