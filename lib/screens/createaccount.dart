import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Footer.dart';
import '../utils/constants/colors.dart';
import '../version.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    if (mounted) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign up success (simulated)!")),
      );

      context.go('/dashboard'); // Navigate after successful sign-up
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Form(
              key: _formKey,
              child: Container(
                width: isWeb ? 450 : double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/Logo_Square.png",
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 10),
        
                    const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Sign up to get started", style: TextStyle(color: Colors.grey)),
        
                    const SizedBox(height: 20),
        
                    TextFormField(
                      controller: _companyIdController,
                      decoration: _inputDecoration("Company ID", Icons.business),
                      validator: (val) => val == null || val.isEmpty ? "Please enter your Company ID" : null,
                    ),
                    const SizedBox(height: 15),
        
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Email", Icons.email_outlined),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Please enter your email";
                        if (!val.contains("@")) return "Please enter a valid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
        
                    TextFormField(
                      controller: _usernameController,
                      decoration: _inputDecoration("Username", Icons.person_outline),
                      validator: (val) => val == null || val.isEmpty ? "Please enter a username" : null,
                    ),
                    const SizedBox(height: 15),
        
                    TextFormField(
                      controller: _fullNameController,
                      decoration: _inputDecoration("Full Name", Icons.person_outline),
                      validator: (val) => val == null || val.isEmpty ? "Please enter your full name" : null,
                    ),
                    const SizedBox(height: 15),
        
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("Phone Number", Icons.phone),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Please enter your phone number";
                        if (val.length < 10) return "Enter a valid phone number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
        
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: _inputDecoration(
                        "Password",
                        Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Please enter a password";
                        if (val.length < 6) return "Password must be at least 6 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
        
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: _inputDecoration(
                        "Confirm Password",
                        Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: _toggleConfirmPasswordVisibility,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Please confirm your password";
                        if (val != _passwordController.text) return "Passwords do not match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
        
                    SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.color2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
        
                    const SizedBox(height: 20),
        
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            "Login",
                            style: TextStyle(color: MyColors.color2, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
        
                    Text(appVersion, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    AppFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
