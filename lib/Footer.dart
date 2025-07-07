import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔶 Gradient Divider
          Container(
            height: 3,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFA726), // Orange
                  Color(0xFFFFC107), // Amber
                  Color(0xFF8BC34A), // Light Green
                  Color(0xFF4CAF50), // Green
                ],
                stops: [0.0, 0.33, 0.66, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🔷 Logo and Copyright
          Column(
            children: [
              Image.asset(
                "assets/images/Logo_Square.png",
                width: 50,
                height: 50,
              ),
              const SizedBox(height: 10),
              const Text(
                "© 2025 Luminara - Light Level Psychological Solutions. All rights reserved.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
