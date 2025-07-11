import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 5 : 24,
        horizontal: isSmallScreen ? 16 : 40,
      ),
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
                  Color(0xFFFFA726),
                  Color(0xFFFFC107),
                  Color(0xFF8BC34A),
                  Color(0xFF4CAF50),
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
                width: isSmallScreen ? 40 : isTablet ? 48 : 60,
                height: isSmallScreen ? 40 : isTablet ? 48 : 60,
              ),
              const SizedBox(height: 10),
              Text(
                "© 2025 Luminara - Light Level Psychological Solutions. All rights reserved.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: isSmallScreen ? 11 : isTablet ? 12 : 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
