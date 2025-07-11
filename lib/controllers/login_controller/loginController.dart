import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/userProvider.dart';
import '../../utils/storage/user_storage.dart';

class LoginController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStorage _userStorage = UserStorage();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  Future<void> checkAndStoreSafeCommunityAccess() async {
    final bool? localAccess = _userStorage.getSafeCommunityAccess();

    if (localAccess != null) {
      debugPrint("✅ safeCommunityAccess loaded from local storage: $localAccess");
      return;
    }

    final String? companyId = _userStorage.getCompanyId();
    if (companyId == null) {
      debugPrint("⚠️ No companyId found in local storage.");
      return;
    }

    try {
      final doc = await _firestore.collection("companies").doc(companyId).get();
      if (doc.exists && doc.data()!.containsKey("safeCommunityAccess")) {
        bool safeAccess = doc["safeCommunityAccess"] == true;
        _userStorage.saveSafeCommunityAccess(safeAccess);
        debugPrint("📥 safeCommunityAccess fetched from Firestore: $safeAccess");
      } else {
        debugPrint("⚠️ No 'safeCommunityAccess' field found for companyId: $companyId.");
      }
    } catch (e) {
      debugPrint("❌ Error fetching safeCommunityAccess: $e");
    }
  }

  Future<void> login(BuildContext context) async {
    final String email = emailController.text.trim().toLowerCase();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError(context, "Email and password are required.");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      debugPrint("✅ Firebase Auth UID: $uid");

      final userDoc = await _firestore.collection("users").doc(uid).get();
      if (!userDoc.exists) {
        _showError(context, "User profile not found. Please contact support.");
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      await _userStorage.clearUid();
      await _userStorage.saveUid(uid);

      if (userData.containsKey('fullName')) {
        _userStorage.saveFullName(userData['fullName']);
      }
      if (userData.containsKey('companyId')) {
        _userStorage.saveCompanyId(userData['companyId']);
      }
      if (userData.containsKey('username')) {
        _userStorage.saveUsername(userData['username']);
      }

      await Future.delayed(const Duration(milliseconds: 300));
      await _userStorage.saveFCMToken();
      await checkAndStoreSafeCommunityAccess();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData(); // loads from GetStorage, updates state

      context.go('/home');
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'user-not-found' => "No user found with this email.",
        'wrong-password' => "Incorrect password.",
        _ => "Login failed. Please try again.",
      };
      _showError(context, message);
    } catch (e) {
      _showError(context, "Something went wrong: ${e.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout(BuildContext context) {
    _auth.signOut();
    _userStorage.clearUid();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadUserData(); // loads from GetStorage, updates state
    notifyListeners();
    context.go('/login');
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
