import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:url_launcher/url_launcher.dart';

import '../utils/constants/colors.dart';
import '../version.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  Timer? _cooldownTimer;
  int _cooldownSeconds = 120; // 2 minutes in seconds
  bool _isCooldown = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _cooldownSeconds = 120; // Reset to 2 minutes
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_cooldownSeconds > 0) {
          _cooldownSeconds--;
        } else {
          _isCooldown = false;
          timer.cancel();
        }
      });
    });
  }

  // Helper function to format seconds into "mm:ss" format
  String _formatCooldown(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _launchEmailApp() async {
    try {
      final Uri url = Uri.parse('mailto:');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar(
          'Error',
          'Could not open email app. Please check your email manually.',
          snackPosition: SnackPosition.BOTTOM,
          mainButton: TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        );
      }
    } on Exception catch (e) {
      Get.snackbar(
        'Error',
        'Failed to launch email app: ${e.toString().split(':').last}',
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
    }
  }

  void _handlePasswordReset() {
    if (_isCooldown) return;

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Simulate email sending
    setState(() => _emailSent = true);
    _startCooldown();

    Get.snackbar(
      'Success',
      'Password reset email sent! Please check your inbox',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  "assets/images/logo/Logo_Square.png",
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  "Enter your email to receive reset instructions",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Email TextField
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Reset Password Button
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: AbsorbPointer(
                    absorbing: _isCooldown,
                    child: InkWell(
                      onTap: _handlePasswordReset,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: _isCooldown
                                ? [Colors.grey, Colors.grey] // 2 colors
                                : [
                              const Color(0xFFFFA726),
                              const Color(0xFFFFC107),
                              const Color(0xFF8BC34A),
                              const Color(0xFF4CAF50),
                            ], // 4 colors
                            stops: _isCooldown
                                ? [0.0, 1.0] // 2 stops
                                : [0.0, 0.33, 0.67, 1.0], // 4 stops
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: _isCooldown
                                  ? [Colors.grey, Colors.grey] // 2 colors
                                  : [
                                const Color(0xFFFFA726),
                                const Color(0xFFFFC107),
                              ], // 2 colors
                              stops: _isCooldown
                                  ? [0.0, 1.0] // 2 stops
                                  : [0.0, 1.0], // 2 stops
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              _isCooldown
                                  ? 'Resend in ${_formatCooldown(_cooldownSeconds)}' // Display as "mm:ss"
                                  : 'Reset Password',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (_emailSent) ...[
                  const SizedBox(height: 20),
                  // Open Email App Button
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: InkWell(
                      onTap: _launchEmailApp,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFA726),
                              Color(0xFFFFC107),
                              Color(0xFF8BC34A),
                              Color(0xFF4CAF50),
                            ],
                            stops: [0.0, 0.33, 0.67, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child:  ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Color(0xFFFFA726),
                                Color(0xFFFFC107),
                              ],
                              stops: [0.0, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'Open Email App',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                // Back to Login Button
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    "Back to Login",
                    style: TextStyle(
                      fontSize: 14,
                      color: MyColors.color2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Text(appVersion,style: TextStyle(color: Colors.grey, fontSize: 14),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}