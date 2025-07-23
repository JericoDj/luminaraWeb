import 'dart:async'; // Import for Timer functionality
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../controllers/call_controller.dart';

import '../../test/test/services/webrtc_service.dart';
import '../../utils/constants/colors.dart';
import '../../widgets/navigation_bar.dart';
import 'call_ended_screen.dart';

class CallingCustomerSupportScreen extends StatefulWidget {
  final String? roomId;
  final bool isCaller;
  final String? userId;CallingCustomerSupportScreen({
    Key? key,
    required this.roomId,
    required this.isCaller,
    this.userId,
  }) : super(key: key);

  @override
  _CallingScreenState createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingCustomerSupportScreen> {
  late CallController _callController;
  bool isMicMuted = false;
  bool isSpeakerMuted = false;
  bool connectingLoading = true;
  String? _currentRoomId;
  String? _currentUserId;

  // ✅ Timer State
  Timer? _callDurationTimer;
  int _callDurationSeconds = 0; // Duration in seconds
  String get formattedCallDuration {
    final minutes = _callDurationSeconds ~/ 60;
    final seconds = _callDurationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isEndingCall = false;


  // ✅ New Variable to Track Queue Count
  int _waitingCount = 0;




  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _currentRoomId = widget.roomId;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _currentUserId = user.uid;
        });
      }
    });

    _callController = CallController(
      fbCallService: WebRtcService(),
      onRoomIdGenerated: (newRoomId) async {
        setState(() {
          _currentRoomId = newRoomId;
        });

        await _ensureUserIdIsReady();

        if (_currentUserId != null) {
          _saveRoomToFirestore(newRoomId);
        }
      },
      onCallEnded: _leaveCall,
      onConnectionEstablished: _connectingLoadingCompleted,
      onStateChanged: () {},
    );

    Future.delayed(const Duration(milliseconds: 100), () async {
      await _callController.openCamera();
      _callController.init(_currentRoomId);
    });

    // ✅ Start Listening for Status Change to 'ongoing'
    _listenForCallStatus();
  }

  // ✅ Listen for Status Change to "ongoing"
  // ✅ Enhanced Status Listener with Immediate UI Update
  void _listenForCallStatus() async {
    if (_currentUserId == null) {
      await _ensureUserIdIsReady();
    }

    if (_currentUserId != null) {
      FirebaseFirestore.instance
          .collection("customer_support/voice/sessions")
          .doc(_currentUserId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final status = snapshot['status'];
          debugPrint("🔥 Firestore Status Updated: $status");

          if (status == 'ongoing') {
            _startCallDurationTimer();

            if (mounted) {
              setState(() {
                connectingLoading = false;  // ✅ Switch to "Duration" view
              });
            }
          }
        } else {
          debugPrint("❌ Error: Firestore snapshot doesn't exist.");
        }
      }, onError: (error) {
        debugPrint("❌ Firestore Listener Error: $error");
      });
    } else {
      debugPrint("❌ ERROR: Failed to initialize _currentUserId for Firestore listener.");
    }
  }


  // ✅ Timer Function
  void _startCallDurationTimer() {
    _callDurationTimer?.cancel(); // Cancel any previous timer
    _callDurationSeconds = 0; // Reset timer

    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }


  // ✅ Timer Cleanup
  void _stopCallDurationTimer() {
    _callDurationTimer?.cancel();
  }

  // ✅ Improved Retry Logic for _ensureUserIdIsReady
  Future<void> _ensureUserIdIsReady() async {
    const int maxRetries = 5;
    const Duration retryDelay = Duration(milliseconds: 500);

    int attempts = 0;

    while (_currentUserId == null && attempts < maxRetries) {
      debugPrint("⏳ Waiting for UID... (Attempt $attempts)");
      await Future.delayed(retryDelay);
      _currentUserId = FirebaseAuth.instance.currentUser?.uid;
      attempts++;
    }

    if (_currentUserId == null) {
      debugPrint("❌ ERROR: Failed to retrieve UID after retries.");
    } else {
      debugPrint("✅ UID Found: $_currentUserId");
    }
  }

  Future<void> _saveRoomToFirestore(String roomId) async {
    _currentUserId ??= FirebaseAuth.instance.currentUser?.uid;

    if (_currentUserId == null) {
      await _ensureUserIdIsReady();
      if (_currentUserId == null) return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("customer_support/voice/sessions")
          .doc(_currentUserId)
          .set({
        'sessionType': 'Customer Support',
        'userId': _currentUserId,
        'roomId': roomId,
        'status': 'waiting',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("❌ Error saving room ID: $e");
    }
  }

  void _connectingLoadingCompleted() {
    if (mounted) {
      setState(() {
        connectingLoading = false;
      });
    }
  }

  void _leaveCall() async {
    setState(() => _isEndingCall = true);
    if (_currentRoomId != null && _currentUserId != null) {
      // ✅ Step 1: Update Firestore Status to 'finished'
      try {
        await FirebaseFirestore.instance
            .collection("customer_support/voice/sessions")
            .doc(_currentUserId)
            .update({'status': 'finished'});
        debugPrint("✅ Firestore Status Updated to 'finished'");
      } catch (e) {
        debugPrint("❌ Error Updating Firestore Status: $e");
      }



      // ✅ Step 3: Delete Firebase Document (Cleanup)
      try {
        await _callController.fbCallService.deleteFirebaseDoc(roomId: _currentRoomId!);
        debugPrint("🔥 Firestore Document Deleted Successfully");
      } catch (e) {
        debugPrint("❌ Error Deleting Firestore Document: $e");
      }

      // ✅ Step 4: Stop Media Tracks and Release Resources
      if (_callController.localStream != null) {
        _callController.localStream?.getTracks().forEach((track) {
          track.stop();
        });
        await _callController.localStream?.dispose();
      }

      await _callController.localVideo.dispose();
      await _callController.remoteVideo.dispose();
      await _callController.peerConnection?.dispose();

      // ✅ Step 5: Stop Call Duration Timer
      _stopCallDurationTimer();

      // ✅ Step 6: Navigate to Call Ended Screen
      if (mounted) {
        context.go('/call-ended');
      }
    } else {
      debugPrint("❌ ERROR: Room ID or User ID is null. Unable to leave the call.");
    }
  }



  @override
  void dispose() {
    _stopCallDurationTimer();
    WakelockPlus.disable();
    // ✅ Ensure timer is stopped when leaving screen
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
            // Caller Information
            Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/avatars/Avatar1.jpeg"),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Customer Support",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  connectingLoading
                      ? (_waitingCount > 0
                      ? "$_waitingCount waiting in queue..."
                      : " Waiting for available agent...")
                      : "Duration: $formattedCallDuration",
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
                    // GestureDetector(
                    //   onTap: _leaveCall,
                    //   child: CircleAvatar(
                    //     radius: 40,
                    //     backgroundColor: Colors.redAccent,
                    //     child: const Icon(
                    //       Icons.call_end,
                    //       color: Colors.white,
                    //       size: 40,
                    //     ),
                    //   ),
                    // ),
                    //
                    //
                    // GestureDetector(
                    //   onTap: () async {
                    //     final newSpeakerState = !isSpeakerMuted;
                    //     await _callController.toggleSpeaker(newSpeakerState);
                    //     setState(() {
                    //       isSpeakerMuted = newSpeakerState;
                    //     });
                    //   },
                    //   child: Column(
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.all(4),
                    //         decoration: BoxDecoration(
                    //           shape: BoxShape.circle,
                    //           border: Border.all(color: MyColors.color2, width: 2),
                    //         ),
                    //         child: CircleAvatar(
                    //           radius: 30,
                    //           backgroundColor: Colors.white,
                    //           child: Icon(
                    //             isSpeakerMuted ? Icons.volume_up : Icons.volume_down_sharp,
                    //             color: MyColors.color2,
                    //             size: 30,
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 8),
                    //       Text(isSpeakerMuted ? "Speaker on" : "Speaker Off"),
                    //     ],
                    //   ),
                    // ),

                  ],
                ),

                const SizedBox(height: 30),

                _isEndingCall
                    ? const CircularProgressIndicator()
                    : GestureDetector(
                  onTap: _leaveCall,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.redAccent,
                    child: const Icon(
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
}
