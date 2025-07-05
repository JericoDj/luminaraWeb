import 'package:flutter/material.dart';

class AccountPrivacyPage extends StatelessWidget {
  const AccountPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF8F8F8),
                      Color(0xFFF1F1F1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              /// Gradient Bottom Border
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2, // Border thickness
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange, // Start - Orange
                        Colors.orangeAccent, // Stop 2 - Orange Accent
                        Colors.green, // Stop 3 - Green
                        Colors.greenAccent, // Stop 4 - Green Accent
                      ],
                      stops: const [0.0, 0.5, 0.5, 1.0], // Define stops at 50% transition
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: const Text('Account Privacy'),
        ),
        body: SingleChildScrollView(  // Wrap the body in SingleChildScrollView for scrolling
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                textAlign: TextAlign.center,
                'Data Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                textAlign: TextAlign.center,
                'Learn about how we handle your data and your privacy rights.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                textAlign: TextAlign.center,
                'At Luminara, your mental well-being is our top priority. We are committed to protecting your personal information and providing a safe, supportive environment. Luminira collects minimal data necessary to offer personalized mental health resources and never shares your data with third parties without your explicit consent. You have complete control over your account settings to manage your data, adjust privacy preferences, or delete your account when needed.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                textAlign: TextAlign.center,
                'We also provide comprehensive terms of use to explain our data handling practices. If you need support or have questions about your privacy, our Care Team is always available to assist you. Luminara is dedicated to fostering a secure, compassionate space where you can prioritize your mental health with confidence.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  textAlign: TextAlign.center,
                  'Terms of Use',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                textAlign: TextAlign.center,
                'By using Luminara, you agree to the following terms and conditions. Our platform provides resources and support for mental health but does not replace professional medical advice. Users are encouraged to consult with licensed professionals for diagnosis and treatment. Luminara reserves the right to update these terms at any time. Continued use of the app signifies acceptance of the updated terms. Misuse of the platform, including inappropriate behavior or sharing harmful content, may result in account suspension or termination.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                textAlign: TextAlign.center,
                'For full details, please refer to our official Terms of Use document available on our website or within the app settings.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
