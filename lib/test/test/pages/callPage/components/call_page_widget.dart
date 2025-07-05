import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../../controllers/call_controller.dart';
import '../../../../../screens/homescreen/call_ended_screen.dart';

class CallPageWidget extends StatefulWidget {
  final bool connectingLoading;
  final String roomId;
  final bool isCaller;
  final RTCVideoRenderer remoteVideo;
  final RTCVideoRenderer localVideo;
  final VoidCallback leaveCall;
  final VoidCallback switchCamera;
  final VoidCallback toggleCamera;
  final VoidCallback toggleMic;
  final bool isAudioOn;
  final bool isVideoOn;
  final String? sessionType;
  final String? userId;
  final CallController callController;

  const CallPageWidget({
    super.key,
    required this.connectingLoading,
    required this.callController,
    required this.roomId,
    required this.isCaller,
    required this.remoteVideo,
    required this.localVideo,
    required this.leaveCall,
    required this.switchCamera,
    required this.toggleCamera,
    required this.toggleMic,
    required this.isAudioOn,
    required this.isVideoOn,
    this.sessionType,
    this.userId,
  });

  @override
  State<CallPageWidget> createState() => _CallPageWidgetState();
}

class _CallPageWidgetState extends State<CallPageWidget> {

  late CallController _callController;


  bool isMicMuted = false;
  bool isSpeakerMuted = false;
  bool isSpeakerOn = true; // Speaker initially ON
  StreamSubscription<DocumentSnapshot>? _statusSubscription;

  @override
  void initState() {
    super.initState();

    _callController = widget.callController; // ✅ Assign the passed controller

    // ✅ Track Call Status in Real-Time
    _trackCallStatus();
  }

  /// ✅ Firestore Listener to Track Call Status
  void _trackCallStatus() {
    if (widget.sessionType != null && widget.userId != null) {
      String collectionPath = "safe_talk/${widget.sessionType!.toLowerCase()}/queue";

      _statusSubscription = FirebaseFirestore.instance
          .collection(collectionPath)
          .doc(widget.userId)
          .snapshots()
          .listen((snapshot) {
        if (!snapshot.exists) return;

        var data = snapshot.data() as Map<String, dynamic>;

        if (data['status'] == 'ended') {
          // ✅ Automatically Redirect to Call Ended Screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CallEndedScreen(), // ✅ Navigate to Call Ended Screen
              ),
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avatar, Title, Call Status
            Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/avatars/Avatar1.jpeg"),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Mental Health Specialist",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.connectingLoading
                      ? "Waiting for available Mental Health Specialist..."
                      : "In Call",
                  textAlign: TextAlign.center,
                  style: const TextStyle(

                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            // Action Buttons
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mic Button
                    GestureDetector(
                      onTap: () {
                        widget.toggleMic(); // ✅ Call the passed-in function

                        // Try to reflect mic state UI-wise
                        setState(() {
                          isMicMuted = !isMicMuted;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade700, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(
                                isMicMuted ? Icons.mic_off : Icons.mic,
                                color: Colors.grey.shade700,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(isMicMuted ? "Unmute" : "Mute"),
                        ],
                      ),
                    ),

                    // Speaker Button
                    GestureDetector(
                      onTap: () async {
                        final newSpeakerState = !isSpeakerMuted;
                        await _callController.toggleSpeaker(newSpeakerState);
                        setState(() {
                          isSpeakerMuted = newSpeakerState;

                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade700, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(
                                isSpeakerMuted ? Icons.volume_up : Icons.volume_off,
                                color: Colors.grey.shade700,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(isSpeakerMuted ? "Speaker On" : "Speaker Off"),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // End Call Button
                GestureDetector(
                  onTap: widget.leaveCall,
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.redAccent,
                    child: Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("End Call"),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        debugPrint("🚨 Leave Call button tapped!");
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(1000)),
        ),
        child: Icon(icon, size: 23, color: Colors.white),
      ),
    );
  }
}
