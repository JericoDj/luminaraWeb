import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'userProvider.dart';

class UserTrackingProvider with ChangeNotifier {
  String? _currentFeature;
  String? _currentItemName;
  DateTime? _startTime;

  /// Starts tracking time spent on a feature.
  /// Call this when entering a screen or starting an activity.
  void startTracking(String feature, {String? itemName}) {
    // If already tracking something, stop it first
    if (_currentFeature != null) {
      stopTracking(null); // Passing null context as we don't want to re-fetch provider here
    }

    _currentFeature = feature;
    _currentItemName = itemName;
    _startTime = DateTime.now();
    debugPrint(" iniziato tracking: $_currentFeature \${_currentItemName ?? ''}");
  }

  /// Stops tracking the current feature and logs it to Firestore.
  /// Needs BuildContext to get user info from UserProvider.
  Future<void> stopTracking(BuildContext? context) async {
    if (_currentFeature == null || _startTime == null) return;

    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!).inSeconds;
    final feature = _currentFeature;
    final itemName = _currentItemName;
    
    // Reset local state immediately
    _currentFeature = null;
    _currentItemName = null;
    _startTime = null;

    if (context != null && duration > 0) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await _logToFirestore(
        userProvider: userProvider,
        feature: feature!,
        itemName: itemName,
        durationSeconds: duration,
        startTime: _startTime,
        endTime: endTime,
      );
    }
  }

  /// Logs a one-off event like a button click or selection.
  Future<void> logEvent(BuildContext context, String feature, String itemName, String action) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await _logToFirestore(
      userProvider: userProvider,
      feature: feature,
      itemName: itemName,
      action: action,
    );
  }

  Future<void> _logToFirestore({
    required UserProvider userProvider,
    required String feature,
    String? itemName,
    int? durationSeconds,
    DateTime? startTime,
    DateTime? endTime,
    String? action,
  }) async {
    final companyId = userProvider.companyId ?? "UnknownCompany";
    final fullName = userProvider.fullName ?? "Anonymous";
    final uid = userProvider.uid;

    if (uid == null) return;

    try {
      final logData = {
        'feature': feature,
        'itemName': itemName ?? 'N/A',
        'startTime': startTime != null ? Timestamp.fromDate(startTime) : null,
        'endTime': endTime != null ? Timestamp.fromDate(endTime) : null,
        'durationSeconds': durationSeconds,
        'action': action ?? (durationSeconds != null ? 'time_spent' : 'click'),
        'timestamp': FieldValue.serverTimestamp(),
        'userId': uid,
      };

      // Path: user_tracking/{companyId}/{fullName}/tracking/{randomId}
      await FirebaseFirestore.instance
          .collection('user_tracking')
          .doc(companyId)
          .collection(fullName)
          .doc()
          .set(logData);
      
      debugPrint("✅ Tracking logged: \$feature - \${itemName ?? ''} (\$durationSeconds s)");
    } catch (e) {
      debugPrint("❌ Error logging tracking: \$e");
    }
  }
}
