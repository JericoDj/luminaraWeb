import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:luminarawebsite/Footer.dart';
import '../controllers/login_controller/loginController.dart';
import '../utils/constants/colors.dart';
import '../version.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = LoginController();

  bool isLoading = false;
  bool isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _handleLogin() async {
    setState(() => isLoading = true);

    try {
      await controller.login(context);
      // Navigate on success if needed, e.g., context.go('/dashboard');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Container(
              width: isWeb ? 400 : double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// ✅ Logo
                  Image.asset(
                    "assets/images/Logo_Square.png",
                    width: 150,
                    height: 150,
                  ),
            
                  const SizedBox(height: 10),
            
                  /// ✅ App Name and Subtitle
                  const Text(
                    "LUMINARA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: MyColors.color2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "by",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    "Light Level Psychological Solutions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your partner in mental health",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
            
                  /// ✅ Email
                  TextField(
                    controller: controller.emailController, // 👈 bind here
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
            
                  /// ✅ Password
                  TextField(
                    controller: controller.passwordController, // 👈 bind here
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
            
                  /// ✅ Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/forgot-password'),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: MyColors.color2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
            
                  /// ✅ Sign-In Button
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: isLoading ? null : _handleLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isLoading ? Colors.grey : MyColors.color2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
            
                  /// ✅ Create Account
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => context.go('/signup'),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: MyColors.color2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
            
                  /// ✅ Version Info
                  Text(
                    appVersion,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),

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
