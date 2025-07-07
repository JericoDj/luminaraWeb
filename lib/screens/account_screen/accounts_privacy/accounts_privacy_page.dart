import 'package:flutter/material.dart';

class AccountPrivacyPage extends StatelessWidget {
  const AccountPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1100;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF8F8F8), Color(0xFFF1F1F1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Gradient Bottom Border
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange,
                        Colors.orangeAccent,
                        Colors.green,
                        Colors.greenAccent,
                      ],
                      stops: [0.0, 0.5, 0.5, 1.0],
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 1100 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Data Management',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Learn about how we handle your data and your privacy rights.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'At Luminara, your mental well-being is our top priority. We are committed to protecting your personal information and providing a safe, supportive environment. Luminira collects minimal data necessary to offer personalized mental health resources and never shares your data with third parties without your explicit consent. You have complete control over your account settings to manage your data, adjust privacy preferences, or delete your account when needed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'We also provide comprehensive terms of use to explain our data handling practices. If you need support or have questions about your privacy, our Care Team is always available to assist you. Luminara is dedicated to fostering a secure, compassionate space where you can prioritize your mental health with confidence.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Terms of Use',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'By using Luminara, you agree to the following terms and conditions. Our platform provides resources and support for mental health but does not replace professional medical advice. Users are encouraged to consult with licensed professionals for diagnosis and treatment. Luminara reserves the right to update these terms at any time. Continued use of the app signifies acceptance of the updated terms. Misuse of the platform, including inappropriate behavior or sharing harmful content, may result in account suspension or termination.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'For full details, please refer to our official Terms of Use document available on our website or within the app settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
