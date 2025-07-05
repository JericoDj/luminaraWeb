import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/storage/user_storage.dart';
import '../../widgets/navigation_bar.dart';
import '../login_controller/loginController.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStorage _userStorage = UserStorage(); // User storage for UID
  final loginController = Get.find<LoginController>();

  final formKey = GlobalKey<FormState>();


  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final companyIdController = TextEditingController();
  var isLoading = false.obs;


  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;


  }

  /// **🔹 Sign Up Function**
  Future<void> signUp() async {
    // Validate form first
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final String companyId = companyIdController.text.trim();
    final String email = emailController.text.trim().toLowerCase();
    final String password = passwordController.text.trim();
    final String username = usernameController.text.trim();
    final String fullName = fullNameController.text.trim();
    final String phone = phoneController.text.trim();

    print("📢 [DEBUG] Checking Firestore for company ID: $companyId");

    try {
      // 1. Verify company exists
      final companyRef = await _firestore.collection("companies").doc(companyId).get();
      if (!companyRef.exists) {
        print("❌ Company ID '$companyId' does not exist!");
        Get.snackbar("Error", "Company ID does not exist.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      print("✅ Company ID '$companyId' exists.");

      // 2. Check if email exists in company's users subcollection
      final usersRef = _firestore.collection("companies").doc(companyId).collection("users");
      final userSnapshot = await usersRef.where('email', isEqualTo: email).get();
      if (userSnapshot.docs.isEmpty) {
        print("❌ Email '$email' not registered in company '$companyId'.");
        Get.snackbar("Error", "Your email is not registered under this company.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      print("✅ Email '$email' found under company '$companyId'.");

      // 3. Check if user already exists in Firebase Auth
      User? existingUser;
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          final signInResult = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          existingUser = signInResult.user;

          if (existingUser != null) {
            print("✅ Existing Firebase Auth user found: ${existingUser.uid}");
          } else {
            print("❌ Sign-in succeeded but user object is null.");
          }
        }
      } catch (e) {
        print("⚠️ Firebase Auth lookup failed. Will try to create user.");
      }


      // 4. Create user if not existing
      String uid;
      if (existingUser != null) {
        uid = existingUser.uid;
      } else {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = userCredential.user!.uid;
        print("🔑 New Firebase user created: UID = $uid");
      }

      // 5. Save UID locally
      final userStorage = UserStorage();
      await userStorage.clearUid();
      await userStorage.saveUid(uid);

      // 6. Save user info to Firestore (users collection)
      await _firestore.collection("users").doc(uid).set({
        "uid": uid,
        "email": email,
        "username": username,
        "fullName": fullName,
        "phone": phone,
        "companyId": companyId,
        "24/7_access": false,
      }, SetOptions(merge: true));

      print("✅ User saved in Firestore.");

      // 7. Navigate to main screen



      _userStorage.clearUid();

      // ✅ Save UID immediately
      await _userStorage.saveUid(uid); // Make sure this is `await` if async

      _userStorage.saveFullName(fullName);
      _userStorage.saveCompanyId(companyId);
      _userStorage.saveUsername(username);
      _userStorage.getPhoneNumber(); // Optional depending on app logic
      await _userStorage.saveFCMToken();
      loginController.checkAndStoreSafeCommunityAccess();

      Get.offAll(NavigationBarMenu(dailyCheckIn: true));

      Get.snackbar("Success", "Account created successfully!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error: ${e.message}");
      Get.snackbar("Auth Error", e.message ?? "Account creation failed.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("❌ General Error: $e");
      Get.snackbar("Error", "Something went wrong: ${e.toString()}",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }


}
