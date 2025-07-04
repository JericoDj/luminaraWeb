import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller/loginController.dart';
import '../../utils/constants/colors.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>(); // Get the controller instance

    return Center(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: MyColors.color2, width: 2.5), // Border color
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white, // Button background
        ),
        onPressed: () {
          _showLogoutDialog(context, loginController);
        },
        child: Text(
          'Log Out',
          style: TextStyle(
            color: MyColors.color2, // Text color
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // 📌 SHOW LOGOUT CONFIRMATION DIALOG
  // ────────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context, LoginController loginController) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          "Confirm Logout",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Close dialog
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              loginController.logout(); // ✅ Perform logout
            },
            child: Text(
              "Log Out",
              style: TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
