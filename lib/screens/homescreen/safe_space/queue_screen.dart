import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../controllers/call_controller.dart';

import '../../../controllers/queue_chat_controller.dart';
import '../../../test/test/pages/callPage/components/call_page_widget.dart';

import '../../../test/test/services/webrtc_service.dart';
import '../call_ended_screen.dart';

import 'chat_screen.dart';

class QueueScreen extends StatefulWidget {
  final String sessionType;
  final String userId;
  final String queueDocId;

  const QueueScreen({Key? key, required this.sessionType, required this.userId, required this.queueDocId}) : super(key: key);

  @override
  _QueueScreenState createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> with WidgetsBindingObserver {
  int queuePosition = 1;
  bool isOngoing = false;
  String? callRoom;
  Map<String, dynamic>? _queueData;
  StreamSubscription<DocumentSnapshot>? queueSubscription;
  StreamSubscription<DocumentSnapshot>? ongoingSubscription; // ✅ Added Second Listener
  bool _hasLeftQueue = false;
  bool _isNavigating = false;
  late CallController _callController;
  late ChatController _chatController;
  bool connectingLoading = true;
  String? _currentRoomId;

  @override
  void initState() {
    WakelockPlus.enable(); // 🔒 Keep screen awake
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.sessionType.toLowerCase() == "talk") {
      _monitorTalkStatus();
    } else if (widget.sessionType.toLowerCase() == "chat") {
      _monitorChatStatus();
    }

    _callController = CallController(
      fbCallService: WebRtcService(),
      onRoomIdGenerated: (newRoomId) {
        setState(() {
          _currentRoomId = newRoomId;
          print("🔥 New Room ID: $_currentRoomId");
          _saveRoomToFirestore(newRoomId);
        });
      },
      onCallEnded: _leaveQueue,
      onConnectionEstablished: _connectingLoadingCompleted, onStateChanged: () {  },
    );

    _chatController = ChatController(
      onChatStarted: _connectingLoadingCompleted,
      onChatEnded: _leaveQueue,
    );
  }

  void _connectingLoadingCompleted() {
    if (mounted) {
      setState(() {
        connectingLoading = false;
      });
    }
  }
// ✅ Combined Listener: Monitors Initial Queue Status & Status Changes
  // ✅ Combined Listener: Monitors Initial Queue Status & Status Changes
  bool _hasDetectedOngoing = false; // ✅ Tracks if 'ongoing' has been detected

  // ✅ Listener for TALK sessions
  void _monitorTalkStatus() {
    String collectionPath = "safe_talk/${widget.sessionType.toLowerCase()}/queue";

    queueSubscription = FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(widget.userId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      if (snapshot.exists) {
        _queueData = snapshot.data() as Map<String, dynamic>;

        print("🔥 Updated Firestore Data (Talk): $_queueData");

        setState(() {
          isOngoing = _queueData?["status"] == "ongoing";
          callRoom = _queueData?["callRoom"];
          _currentRoomId = callRoom;
        });

        final status = _queueData?["status"] ?? "";

        if (status == "ongoing" && !_isNavigating && !_hasDetectedOngoing) {
          print("✅ Status Changed to 'ongoing' - Initializing TALK Session...");
          _hasDetectedOngoing = true;

          Future.delayed(const Duration(milliseconds: 100), () async {
            await _callController.openCamera();
            _callController.init(_currentRoomId);
          });
        }

        else if (_hasDetectedOngoing && status != "ongoing" && !_isNavigating) {
          print("✅ Status Changed from 'ongoing' to '$status' - Navigating to CallEndedScreen...");
          _isNavigating = true;

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              context.go('/session-ended');
              print("🚀 Navigation Successful: CallEndedScreen");
            } else {
              print("❌ Navigation Failed: Widget Unmounted");
            }
            _isNavigating = false;
          });
        }
      }
    });

    _trackQueuePosition();
  }



// ✅ Second Listener: Monitors "ongoing" to anything else

  // ✅ Listener for CHAT sessions
  void _monitorChatStatus() {
    String collectionPath = "safe_talk/${widget.sessionType.toLowerCase()}/queue";

    queueSubscription = FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(widget.userId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      if (snapshot.exists) {
        _queueData = snapshot.data() as Map<String, dynamic>;

        print("🔥 Updated Firestore Data (Chat): $_queueData");

        setState(() {
          isOngoing = _queueData?["status"] == "ongoing";
          callRoom = _queueData?["callRoom"];
          _currentRoomId = callRoom;
        });

        final status = _queueData?["status"] ?? "";

        if (status == "ongoing" && !_isNavigating && !_hasDetectedOngoing) {
          print("✅ Status Changed to 'ongoing' - Initializing CHAT Session...");
          _hasDetectedOngoing = true;

          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              context.go('/chat/${widget.userId}');
              print("🚀 Navigation Successful: ChatScreen");
            }
          });
        }

        else if (_hasDetectedOngoing && status != "ongoing" && !_isNavigating) {
          print("✅ Status Changed from 'ongoing' to '$status' - Exiting ChatScreen...");
          _isNavigating = true;

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              context.go('/call-ended');
              print("🚀 Navigation Successful: CallEndedScreen");
            } else {
              print("❌ Navigation Failed: Widget Unmounted");
            }
            _isNavigating = false;
          });
        }
      }
    });

    _trackQueuePosition();
  }





  Timestamp? myTimestamp;
  StreamSubscription<QuerySnapshot>? _positionSub;
  StreamSubscription<DocumentSnapshot>? _selfSub;

  void _trackQueuePosition() {
    String collectionPath = "safe_talk/${widget.sessionType.toLowerCase()}/queue";

    // ✅ 1. Listen to my own document to lock my timestamp
    _selfSub = FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(widget.userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          final ts = data['timestamp'] as Timestamp?;
          if (ts != null && myTimestamp == null) {
            if (mounted) {
              setState(() {
                myTimestamp = ts;
              });
            }
          }
        }
      }
    });

    // ✅ 2. Listen to all users in 'queue' (Sorting in-memory to avoid index requirement)
    _positionSub = FirebaseFirestore.instance
        .collection(collectionPath)
        .where('status', isEqualTo: 'queue')
        .snapshots()
        .listen((snapshot) {
      
      // ✅ Sort documents by timestamp in-memory
      final sortedDocs = snapshot.docs.toList()
        ..sort((a, b) {
          final tsA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          final tsB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          if (tsA == null) return 1;
          if (tsB == null) return -1;
          return tsA.compareTo(tsB);
        });

      // If we don't have our timestamp yet, we can estimate position from the list
      if (myTimestamp == null) {
        int pos = 1;
        for (var doc in sortedDocs) {
          if (doc.id == widget.userId) break;
          pos++;
        }
        if (mounted) setState(() => queuePosition = pos);
        return;
      }

      int aheadOfMe = 0;
      for (var doc in sortedDocs) {
        final data = doc.data() as Map<String, dynamic>;
        final ts = data['timestamp'] as Timestamp?;

        if (ts == null) continue;

        // ✅ Only count users who joined BEFORE me
        if (ts.compareTo(myTimestamp!) < 0) {
          aheadOfMe++;
        }
      }

      if (mounted) {
        setState(() {
          queuePosition = aheadOfMe + 1;
        });
      }
    });
  }



  Future<void> _saveRoomToFirestore(String roomId) async {
    if (widget.sessionType.isEmpty || widget.userId.isEmpty) {
      print("❌ ERROR: Missing sessionType or userId. Cannot save room.");
      return;
    }

    String collectionPath = "safe_talk/${widget.sessionType.toLowerCase()}/queue";

    await FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(widget.userId)
        .set({"callRoom": roomId}, SetOptions(merge: true));

    print("✅ Room ID added to Firestore for admin panel access");
  }

  // ✅ LEAVE CALL: Ends the active session (video call or chat)
  Future<void> _leaveCall() async {
    if (_isNavigating) return;
    _isNavigating = true;

    // ✅ Properly dispose all call resources
    await _callController.dispose(
      context: context,
      userId: widget.userId,
      sessionType: widget.sessionType,
    );

    // ✅ Navigate to Call Ended
    if (mounted) {
      context.go('/call-ended');

      setState(() {
        _isNavigating = false;
        connectingLoading = false;
      });

      print("✅ Successfully ended session and cleaned up.");
    }
  }



  Future<void> _leaveQueue() async {
    if (_hasLeftQueue || _isNavigating) return;
    _hasLeftQueue = true;
  }

  @override
  void dispose() {
    queueSubscription?.cancel();
    ongoingSubscription?.cancel();
    _positionSub?.cancel();
    _selfSub?.cancel();
    WakelockPlus.disable(); // 🔓 Allow screen to sleep again
    WidgetsBinding.instance.removeObserver(this);

    if (!_isNavigating) {
      _leaveQueue();
    }

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (isOngoing && widget.sessionType.toLowerCase() == "talk" && _currentRoomId != null) {
      return CallPageWidget(
        connectingLoading: connectingLoading,
        roomId: _currentRoomId ?? "",
        remoteVideo: _callController.remoteVideo,
        localVideo: _callController.localVideo,
        leaveCall: () => _leaveCall(),
        switchCamera: _callController.switchCamera,
        toggleCamera: (){},
        toggleMic: _callController.toggleMic,
        isAudioOn: _callController.isAudioOn,
        isVideoOn: _callController.isVideoOn,
        isCaller: false, callController: _callController,
      );
    }


    return WillPopScope(
      onWillPop: () async {
        await _leaveQueue();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text("${widget.sessionType} Queue")),
        body: Center(
          child: Text(
            "You are #$queuePosition in the queue for a ${widget.sessionType} session.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
