import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../screens/loginscreen.dart';
import '../../utils/storage/user_storage.dart';
import '../../widgets/navigation_bar.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStorage _userStorage = UserStorage(); // User storage for UID

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isLoading = false.obs; // Loading indicator

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }




  Future<void> checkAndStoreSafeCommunityAccess() async {
    final bool? localAccess = _userStorage.getSafeCommunityAccess();

    if (localAccess != null) {
      print("✅ safeCommunityAccess loaded from local storage: $localAccess");
      return;
    }

    // 🔐 Get the saved companyId from local storage
    final String? companyId = _userStorage.getCompanyId();

    if (companyId == null) {
      print("⚠️ No companyId found in local storage.");
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection("companies").doc(companyId).get();

      if (doc.exists && doc.data()!.containsKey("safeCommunityAccess")) {
        bool safeAccess = doc["safeCommunityAccess"] == true;
        _userStorage.saveSafeCommunityAccess(safeAccess);
        print("📥 safeCommunityAccess fetched from Firestore: $safeAccess");
      } else {
        print("⚠️ No 'safeCommunityAccess' field found for companyId: $companyId.");
      }
    } catch (e) {
      print("❌ Error fetching safeCommunityAccess for companyId $companyId: $e");
    }
  }


  Future<void> login() async {
    String email = emailController.text.trim().toLowerCase();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter both email and password",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // ✅ Step 1: Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print("✅ Firebase Auth UID: $uid");

      // ✅ Step 2: Retrieve user profile from Firestore
      DocumentSnapshot userDoc =
      await _firestore.collection("users").doc(uid).get();

      if (!userDoc.exists) {
        Get.snackbar("Error", "User profile not found. Please contact support.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        isLoading.value = false;
        return;
      }

      var userData = userDoc.data() as Map<String, dynamic>;
      print("📌 Firestore User Data: $userData");

      // ✅ Clear any old login data
      _userStorage.clearUid();

      // ✅ Save UID immediately
      await _userStorage.saveUid(uid); // Make sure this is `await` if async

      // ✅ Save other user details
      if (userData.containsKey('fullName')) {
        String fullName = userData['fullName'];
        _userStorage.saveFullName(fullName);
        print("📝 Full Name saved: $fullName");
      } else {
        print("⚠️ No fullName found in user profile.");
      }

      if (userData.containsKey('companyId')) {
        String companyId = userData['companyId'];
        _userStorage.saveCompanyId(companyId);
        print("🏢 Company ID saved: $companyId");
      } else {
        print("⚠️ No companyId found in user profile.");
      }

      if (userData.containsKey('username')) {
        String username = userData['username'];
        _userStorage.saveUsername(username);
        print("👤 Username saved: $username");
      } else {
        print("⚠️ No username found in user profile.");
      }

      _userStorage.getPhoneNumber(); // Optional depending on app logic

      // ✅ Step 3: Save FCM Token after UID is safely stored
      await Future.delayed(Duration(milliseconds: 300));
      await _userStorage.saveFCMToken();

      // ✅ Step 4: Check access rights
      await checkAndStoreSafeCommunityAccess();

      // ✅ Step 5: Navigate to dashboard
      Get.offAll(() => NavigationBarMenu(dailyCheckIn: true));

      // Get.snackbar("Success", "Login successful!",
      //     snackPosition: SnackPosition.BOTTOM,
      //     backgroundColor: Colors.green,
      //     colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      }

      Get.snackbar("Error", errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } catch (e) {
      print("❌ Login Error: $e");
      Get.snackbar("Error", "Something went wrong: ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }




  /// **✅ Logout Function**
  void logout() {
    _auth.signOut(); // Firebase sign out
    _userStorage.clearUid(); // Clear local storage
    Get.offAll(() => LoginScreen()); // Navigate back to login
    Get.snackbar("Success", "Logged out successfully.",
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
  }
}
