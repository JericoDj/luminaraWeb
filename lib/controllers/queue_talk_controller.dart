import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../test/test/services/webrtc_service.dart';
import 'call_controller.dart';

class TalkController extends GetxController {
  final String sessionType;
  final String userId;

  TalkController(this.sessionType, this.userId);

  // Reactive variables
  final RxInt queuePosition = 1.obs;
  final RxBool isOngoing = false.obs;
  final RxString callRoom = RxString('');
  final RxMap<String, dynamic> queueData = RxMap<String, dynamic>();
  final RxBool hasLeftQueue = false.obs;
  final RxBool isNavigating = false.obs;
  final RxBool connectingLoading = true.obs;
  final RxString currentRoomId = RxString('');

  late CallController _callController; // Private CallController instance

  // Public getter for CallController
  CallController get callController => _callController;

  StreamSubscription<DocumentSnapshot>? queueSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeCallController();
    _monitorQueueStatus();
  }

  void _initializeCallController() {
    _callController = CallController(
      fbCallService: WebRtcService(),
      onRoomIdGenerated: (newRoomId) {
        currentRoomId.value = newRoomId;
        _saveRoomToFirestore(newRoomId);
      },
      onCallEnded: leaveQueue,
      onConnectionEstablished: () => connectingLoading.value = false, onStateChanged: () {  },
    );
  }

  void _monitorQueueStatus() {
    final collectionPath = "safe_talk/${sessionType.toLowerCase()}/queue";

    queueSubscription = FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        queueData.value = snapshot.data() as Map<String, dynamic>;
        _updateStatusFromData();
        _checkForFinishedStatus();
      }
    });

    _trackQueuePosition();
  }

  void _updateStatusFromData() {
    isOngoing.value = queueData['status'] == 'ongoing';
    callRoom.value = queueData['callRoom'] ?? '';
    currentRoomId.value = callRoom.value;
  }

  void _checkForFinishedStatus() {
    if (queueData['status'] == 'finished' && !isNavigating.value) {
      isNavigating.value = true;
    }
  }

  Timestamp? myTimestamp;
  StreamSubscription<QuerySnapshot>? _positionSub;
  StreamSubscription<DocumentSnapshot>? _selfSub;

  void _trackQueuePosition() {
    final collectionPath = "safe_talk/${sessionType.toLowerCase()}/queue";

    // ✅ 1. Listen to my own document to lock my timestamp
    _selfSub = FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final ts = data['timestamp'];
        if (ts != null && myTimestamp == null) {
          myTimestamp = ts;
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
          if (doc.id == userId) break;
          pos++;
        }
        queuePosition.value = pos;
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

      queuePosition.value = aheadOfMe + 1;
    });
  }



  Future<void> _saveRoomToFirestore(String roomId) async {
    final collectionPath = "safe_talk/${sessionType.toLowerCase()}/queue";

    await FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(userId)
        .set({'callRoom': roomId}, SetOptions(merge: true));
  }

  Future<void> leaveQueue() async {
    if (hasLeftQueue.value || isNavigating.value) return;
    hasLeftQueue.value = true;
    await queueSubscription?.cancel();
    await _positionSub?.cancel();
    await _selfSub?.cancel();
  }


  Future<void> handleCallStart() async {
    if (isOngoing.value && sessionType.toLowerCase() == "talk") {
      await _callController.openCamera();
      _callController.init(currentRoomId.value);
    }
  }

}