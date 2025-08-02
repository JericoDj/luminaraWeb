import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/userProvider.dart';
import '../../utils/storage/user_storage.dart';
import '../login_controller/loginController.dart';

class SignUpController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStorage _userStorage = UserStorage();

  final formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final companyIdController = TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    final String companyId = companyIdController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String username = usernameController.text.trim();
    final String fullName = fullNameController.text.trim();
    final String phone = phoneController.text.trim();

    try {
      // Step 1: Validate company ID
      final companyRef = await _firestore.collection("companies").doc(companyId).get();
      if (!companyRef.exists) {
        _showSnackBar(context, "Company ID does not exist.", Colors.red);
        return;
      }

      // Step 2: Validate email under company
      final usersRef = _firestore.collection("companies").doc(companyId).collection("users");
      final userSnapshot = await usersRef.where('email', isEqualTo: email).get();
      if (userSnapshot.docs.isEmpty) {
        _showSnackBar(context, "Your email is not registered under this company.", Colors.red);
        return;
      }

      // Step 3: Check for existing Auth user
      User? existingUser;
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          final signInResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
          existingUser = signInResult.user;
        }
      } catch (_) {}

      // Step 4: Create or reuse user
      String uid;
      if (existingUser != null) {
        uid = existingUser.uid;
      } else {
        final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        uid = userCredential.user!.uid;
      }

      // Step 5: Store UID
      await _userStorage.clearUid();
      await _userStorage.saveUid(uid);

      // Step 6: Save profile data
      await _firestore.collection("users").doc(uid).set({
        "uid": uid,
        "email": email,
        "username": username,
        "fullName": fullName,
        "phone": phone,
        "companyId": companyId,
        "24/7_access": false,
      }, SetOptions(merge: true));

      // Step 7: Save locally
      _userStorage.saveFullName(fullName);
      _userStorage.saveCompanyId(companyId);
      _userStorage.saveUsername(username);
      _userStorage.savePhoneNumber(phone);
      await _userStorage.saveFCMToken();

      final loginController = Provider.of<LoginController>(context, listen: false);
      await loginController.checkAndStoreSafeCommunityAccess();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData();

      context.go('/home');
      _showSnackBar(context, "Account created successfully!", Colors.green);
    } on FirebaseAuthException catch (e) {
      _showSnackBar(context, e.message ?? "Account creation failed.", Colors.red);
    } catch (e) {
      _showSnackBar(context, "Something went wrong: ${e.toString()}", Colors.red);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
