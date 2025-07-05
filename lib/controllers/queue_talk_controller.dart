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

  void _trackQueuePosition() {
    final collectionPath = "safe_talk/${sessionType.toLowerCase()}/queue";

    FirebaseFirestore.instance
        .collection(collectionPath)
        .orderBy("timestamp", descending: false)
        .snapshots()
        .listen((snapshot) {
      int position = 1;
      for (var doc in snapshot.docs) {
        if (doc.id == userId) break;
        position++;
      }
      queuePosition.value = position;
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
  }

  Future<void> handleCallStart() async {
    if (isOngoing.value && sessionType.toLowerCase() == "talk") {
      await _callController.openCamera();
      _callController.init(currentRoomId.value);
    }
  }

}