import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../test/test/pages/callPage/call_page.dart';
import '../call_ended_screen.dart';
import 'chat_screen.dart';

class QueueScreen extends StatefulWidget {
  final String sessionType;
  final String userId;

  const QueueScreen({
    super.key,
    required this.sessionType,
    required this.userId,
  });

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  StreamSubscription<DocumentSnapshot>? _queueSub;
  StreamSubscription<DocumentSnapshot>? _selfSub;
  StreamSubscription<QuerySnapshot>? _positionSub;

  int queuePosition = 1;
  Timestamp? myTimestamp;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    _listenMyTimestamp();
    _listenQueueStatus();
    _listenQueuePosition();
  }

  // ----------------------------------------------------------
  // LISTEN TO OWN DOCUMENT → GET TIMESTAMP (for queue ordering)
  // ----------------------------------------------------------
  void _listenMyTimestamp() {
    final docPath =
        "safe_talk/${widget.sessionType.toLowerCase()}/queue/${widget.userId}";

    _selfSub = FirebaseFirestore.instance.doc(docPath).snapshots().listen(
          (snapshot) {
        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>;
        final ts = data["timestamp"];

        if (ts != null && myTimestamp == null) {
          myTimestamp = ts;
        }
      },
    );
  }

  // ----------------------------------------------------------
  // LISTEN FOR CHAT / TALK SESSION STATUS
  // ----------------------------------------------------------
  void _listenQueueStatus() {
    final docPath =
        "safe_talk/${widget.sessionType.toLowerCase()}/queue/${widget.userId}";

    _queueSub = FirebaseFirestore.instance.doc(docPath).snapshots().listen(
          (snapshot) async {
        if (!snapshot.exists || !mounted) return;

        final data = snapshot.data() as Map<String, dynamic>;
        final status = data["status"];
        final sessionType = widget.sessionType.toLowerCase();

        // -------------------------------------
        // CHAT SESSION → simply navigate
        // -------------------------------------
        if (status == "ongoing" &&
            !_hasNavigated &&
            sessionType == "chat") {
          _hasNavigated = true;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(userId: widget.userId),
            ),
          );
          return;
        }

        // -------------------------------------
        // TALK SESSION → create room + save + navigate
        // -------------------------------------
        if (status == "ongoing" &&
            !_hasNavigated &&
            sessionType == "talk") {
          _hasNavigated = true;

          // 1) create room ID
          final newRoomId =
              FirebaseFirestore.instance.collection("rooms").doc().id;

          // 2) save the roomId into queue doc
          await FirebaseFirestore.instance
              .collection("safe_talk/talk/queue")
              .doc(widget.userId)
              .set({"callRoom": newRoomId}, SetOptions(merge: true));

          // 3) navigate to call page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CallPage(
                roomId: newRoomId,
                isCaller: true,
              ),
            ),
          );
          return;
        }

        // -------------------------------------
        // SESSION FINISHED → show end screen
        // -------------------------------------
        if (status == "finished" && !_hasNavigated) {
          _hasNavigated = true;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CallEndedScreen()),
          );
        }
      },
    );
  }

  // ----------------------------------------------------------
  // FIXED QUEUE COUNT (follow old mobile逻辑)
  // ----------------------------------------------------------
  void _listenQueuePosition() {
    final colPath =
        "safe_talk/${widget.sessionType.toLowerCase()}/queue";

    _positionSub = FirebaseFirestore.instance
        .collection(colPath)
        .where("status", isEqualTo: "queue")
        .snapshots()
        .listen((snapshot) {
      if (myTimestamp == null) return;

      int aheadOfMe = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ts = data["timestamp"];

        if (ts == null) continue;

        // ------------------------------------------------------
        // Count ONLY users that have a timestamp earlier than me
        // EXACT SAME LOGIC as your previous working mobile app.
        // ------------------------------------------------------
        if (ts.compareTo(myTimestamp!) < 0) {
          aheadOfMe++;
        }
      }

      if (mounted) {
        setState(() {
          queuePosition = aheadOfMe + 1; // my real place in line
        });
      }
    });
  }

  @override
  void dispose() {
    _queueSub?.cancel();
    _selfSub?.cancel();
    _positionSub?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.sessionType} Queue")),
      body: Center(
        child: Text(
          "You are #$queuePosition in queue\nWaiting for ${widget.sessionType}...",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
