import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/carousel_item_model.dart';

class UserStorage {
  final GetStorage _storage = GetStorage();
  static const String _apnTokenKey = 'apnsToken';
  static const String _fcmTokenKey = 'fcmToken';

  // ✅ Save UID locally
  Future<void> saveUid(String uid) async {
    await _storage.write("uid", uid);
  }

  // ✅ Retrieve UID
  String? getUid() {
    return _storage.read("uid");
  }

  // ✅ Save phone number
  void savePhoneNumber(String phoneNumber) {
    _storage.write("phoneNumber", phoneNumber);
  }
  Future<String?> getPhoneNumber() async {
    String? phone = _storage.read("phoneNumber");

    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    // 🔍 Try fetching from Firestore if not found locally
    String? uid = getUid();
    if (uid == null) {
      print("❌ No UID available. Cannot fetch phone number.");
      return null;
    }

    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('phone')) {
          phone = data['phone'];
          // ✅ Save it locally for future use
          _storage.write("phoneNumber", phone);
          print("📞 Phone number fetched from Firestore: $phone");
          return phone;
        }
      }
    } catch (e) {
      print("❌ Error fetching phone number from Firestore: $e");
    }

    return null; // Fallback if everything fails
  }

// ✅ Clear phone number
  void clearPhoneNumber() {
    _storage.remove("phoneNumber");
  }

  Future<void> saveFCMToken() async {
    try {
      // 🔒 Request permission first
      await FirebaseMessaging.instance.requestPermission();

      if (Platform.isIOS) {
        String? apnsToken;
        int retryCount = 0;

        // ⏳ Wait for APNs token to be set (up to 5 seconds)
        while (apnsToken == null && retryCount < 5) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          print("⏳ Waiting for APNs token... attempt ${retryCount + 1}");
          await Future.delayed(Duration(seconds: 1));
          retryCount++;
        }

        if (apnsToken == null) {
          print("⚠️ APNs Token still null after retries. Delaying FCM token registration.");
          return;
        }

        await _storage.write(_apnTokenKey, apnsToken);
        print("📱 APNs Token saved locally: $apnsToken");
      }

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        print("❌ FCM Token is null even after APNs. Double-check Firebase setup.");
        return;
      }

      // 🔍 Get user ID (assuming you have a way to retrieve it)
      final String? uid = _storage.read("uid"); // ✅ Fixed: Specify the correct key // Update this based on how you store user ID

      if (uid == null) {
        print("❌ No user logged in. Cannot save FCM token.");
        return;
      }

      // 🔄 Check the stored token in Firestore before updating
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final storedToken = userDoc.data()?['fcmToken'];

      if (storedToken != fcmToken) {
        // ✅ Only update Firestore if the token has changed
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': fcmToken,
        });
        print("✅ FCM Token updated in Firebase: $fcmToken");
      } else {
        print("🔄 FCM Token is already up-to-date.");
      }

      // Save token locally as well
      await _storage.write(_fcmTokenKey, fcmToken);
      print("✅ FCM Token saved locally: $fcmToken");

    } catch (e) {
      print("❌ Error saving FCM/APNs token: $e");
    }
  }


  // ✅ Save full name
  void saveFullName(String fullName) {
    _storage.write("fullName", fullName);
  }

// ✅ Retrieve full name
  String? getFullName() {
    return _storage.read("fullName");
  }

// ✅ Clear full name
  void clearFullName() {
    _storage.remove("fullName");
  }



  // ✅ Clear UID on logout
  Future<void> clearUid()  async{
    _storage.remove("uid");
    clearMoods();
    clearStressLevels();
    deletePlanDetails();
    clearCompanyId(); // ✅ Also clear company ID
    clearSafeCommunityAccess();
    clearUsername(); // Also clear username
    clearFullName();
    clearPhoneNumber(); // ✅ Added this
  }

  // ✅ Save username locally
  void saveUsername(String username) {
    _storage.write("username", username);
  }

  // ✅ Retrieve username
  String? getUsername() {
    return _storage.read("username");
  }

  // ✅ Clear username on logout
  void clearUsername() {
    _storage.remove("username");
  }




  // ✅ Save company ID locally
  void saveCompanyId(String companyId) {
    _storage.write("company_id", companyId);
  }

// ✅ Retrieve company ID
  String? getCompanyId() {
    return _storage.read("company_id");
  }

// ✅ Clear company ID
  void clearCompanyId() {
    _storage.remove("company_id");
  }


  // ✅ Save safeCommunityAccess flag
  void saveSafeCommunityAccess(bool value) {
    _storage.write("safeCommunityAccess", value);
  }

// ✅ Read safeCommunityAccess from local storage
  bool? getSafeCommunityAccess() {
    return _storage.read("safeCommunityAccess");
  }

// ✅ Clear safeCommunityAccess on logout
  void clearSafeCommunityAccess() {
    _storage.remove("safeCommunityAccess");
  }



  // ✅ Store stress levels locally
  void saveStressLevels(Map<String, int> newStressLevels) {
    final existing = getStoredStressLevels();
    existing.addAll(newStressLevels);
    _storage.write("storedStressLevels", existing);
  }

  // ✅ Retrieve stored stress levels with type safety
  Map<String, int> getStoredStressLevels() {
    final raw = _storage.read("storedStressLevels") as Map<String, dynamic>? ?? {};
    return raw.map<String, int>(
          (key, value) => MapEntry(key, _convertToInt(value)),
    );
  }

  // ✅ Clear stress levels
  void clearStressLevels() {
    _storage.remove("storedStressLevels");
  }

  // ✅ Store stress data locally
  void saveStressData(Map<String, double> newStressData) {
    final existing = getStoredStressData();
    existing.addAll(newStressData);
    _storage.write("storedStressData", existing);
  }

  // ✅ Retrieve stress data with type conversion
  Map<String, double> getStoredStressData() {
    final raw = _storage.read("storedStressData") as Map<String, dynamic>? ?? {};
    return raw.map<String, double>(
          (key, value) => MapEntry(key, _convertToDouble(value)),
    );
  }

  // ✅ Store moods locally
  void saveMoods(Map<String, String> newMoods) {
    final existing = getStoredMoods();
    existing.addAll(newMoods);
    _storage.write("storedMoods", existing);
  }

  // ✅ Retrieve moods with type safety
  Map<String, String> getStoredMoods() {
    final raw = _storage.read("storedMoods") as Map<String, dynamic>? ?? {};
    return raw.map<String, String>(
          (key, value) => MapEntry(key, value.toString()),
    );
  }

  // ✅ Clear moods
  void clearMoods() {
    _storage.remove("storedMoods");
  }

  // ✅ Save plan details
  void savePlanDetails(Map<String, dynamic> planDetails) {
    _storage.write('selectedPlan', planDetails);
  }

  // ✅ Retrieve plan details
  Map<String, dynamic>? getPlanDetails() {
    return _storage.read('selectedPlan') as Map<String, dynamic>?;
  }

  // ✅ Delete plan details
  void deletePlanDetails() {
    _storage.remove('selectedPlan');
  }

  // 🔥 Type conversion helpers
  double _convertToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _convertToInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }


  // ✅ Store carousel items locally
  void saveCarouselItems(List<CarouselItemModel> items) {
    final encoded = items.map((item) => item.toMap()).toList();
    _storage.write('carouselItems', encoded);
  }

// ✅ Retrieve carousel items
  List<CarouselItemModel> getCarouselItems() {
    final rawList = _storage.read('carouselItems') as List<dynamic>? ?? [];
    return rawList.map((e) => CarouselItemModel.fromMap(Map<String, dynamic>.from(e))).toList();
  }

// ✅ Clear carousel items
  void clearCarouselItems() {
    _storage.remove('carouselItems');
  }

}


