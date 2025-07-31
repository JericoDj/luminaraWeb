import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../Footer.dart';
import '../controllers/create_account/create_account_controller.dart';
import '../utils/constants/colors.dart';
import '../version.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final signUpController = Provider.of<SignUpController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Form(
              key: signUpController.formKey,
              child: Container(
                width: isWeb ? 450 : double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset("assets/images/Logo_Square.png", width: 150, height: 150),
                    const SizedBox(height: 10),

                    const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Sign up to get started", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: signUpController.companyIdController,
                      label: "Company ID",
                      icon: Icons.business,
                      validator: (val) => val == null || val.isEmpty ? "Please enter your Company ID" : null,
                    ),
                    _buildTextField(
                      controller: signUpController.emailController,
                      label: "Email",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Please enter your email";
                        if (!val.contains("@")) return "Please enter a valid email";
                        return null;
                      },
                    ),
                    _buildTextField(
                      controller: signUpController.usernameController,
                      label: "Username",
                      icon: Icons.person_outline,
                      validator: (val) => val == null || val.isEmpty ? "Please enter a username" : null,
                    ),
                    _buildTextField(
                      controller: signUpController.fullNameController,
                      label: "Full Name",
                      icon: Icons.person_outline,
                      validator: (val) => val == null || val.isEmpty ? "Please enter your full name" : null,
                    ),
                    _buildTextField(
                      controller: signUpController.phoneController,
                      label: "Phone Number",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Please enter your phone number";
                        if (val.length < 10) return "Enter a valid phone number";
                        return null;
                      },
                    ),

                    Consumer<SignUpController>(
                      builder: (context, c, _) => TextFormField(
                        controller: c.passwordController,
                        obscureText: !c.isPasswordVisible,
                        decoration: _inputDecoration(
                          "Password",
                          Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(c.isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: c.togglePasswordVisibility,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Please enter a password";
                          if (val.length < 6) return "Password must be at least 6 characters";
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 15),

                    Consumer<SignUpController>(
                      builder: (context, c, _) => TextFormField(
                        controller: c.confirmPasswordController,
                        obscureText: !c.isConfirmPasswordVisible,
                        decoration: _inputDecoration(
                          "Confirm Password",
                          Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(c.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                            onPressed: c.toggleConfirmPasswordVisibility,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Please confirm your password";
                          if (val != c.passwordController.text) return "Passwords do not match";
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 25),

                    Consumer<SignUpController>(
                      builder: (context, c, _) => SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: c.isLoading ? null : () => c.signUp(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.color2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: c.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label, icon),
        validator: validator,
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
