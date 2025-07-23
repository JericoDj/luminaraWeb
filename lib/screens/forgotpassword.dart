import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Footer.dart';
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
  int _cooldownSeconds = 120;
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
      _cooldownSeconds = 120;
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
        _showSnackBar('Could not open email app. Please check your email manually.');
      }
    } catch (e) {
      _showSnackBar('Failed to launch email app: ${e.toString().split(':').last}');
    }
  }

  void _handlePasswordReset() async {
    if (_isCooldown) return;

    final email = _emailController.text.trim();
    print('[RESET] Input email: $email');

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email address.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('[RESET] Email sent!');

      setState(() {
        _emailSent = true;
      });

      _startCooldown();
      _showSnackBar('Password reset email sent! Please check your inbox.');
    } on FirebaseAuthException catch (e) {
      print('[RESET] FirebaseAuthException: ${e.code}');
      String errorMessage = 'Something went wrong.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email.';
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      print('[RESET] Unknown error: $e');
      _showSnackBar('Error sending reset email.');
    }
  }



  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     try {
      //       await FirebaseAuth.instance.sendPasswordResetEmail(email: "dejesusjerico528@gmail.com");
      //       print("Email sent!");
      //     } catch (e) {
      //       print("Error: $e");
      //     }
      //   },
      //   child: Icon(Icons.send),
      // ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWeb ? 400 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/Logo_Square.png", width: 150, height: 150),
                  const SizedBox(height: 20),
            
                  const Text("Forgot Password?",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
            
                  const Text("Enter your email to receive reset instructions",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 30),
            
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 30),
            
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
                                  ? [Colors.grey, Colors.grey]
                                  : [
                                const Color(0xFFFFA726),
                                const Color(0xFFFFC107),
                                const Color(0xFF8BC34A),
                                const Color(0xFF4CAF50),
                              ],
                              stops: _isCooldown ? [0.0, 1.0] : [0.0, 0.33, 0.67, 1.0],
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
                                    ? [Colors.grey, Colors.grey]
                                    : [const Color(0xFFFFA726), const Color(0xFFFFC107)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                _isCooldown
                                    ? 'Resend in ${_formatCooldown(_cooldownSeconds)}'
                                    : 'Reset Password',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            
                  if (_emailSent) ...[
                    const SizedBox(height: 20),
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
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  const Color(0xFFFFA726),
                                  const Color(0xFFFFC107),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: const Text(
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
                  TextButton(
                    onPressed: () => context.go("/login"),
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
                  Text(appVersion, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 30),
                  AppFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
