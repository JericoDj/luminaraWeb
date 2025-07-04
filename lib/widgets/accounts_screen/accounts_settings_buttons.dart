import 'package:flutter/material.dart';
import '../../screens/account_screen/accounts_privacy/accounts_privacy_page.dart';
import '../../screens/account_screen/app_settings/app_settings_screen.dart';

import '../../../utils/constants/colors.dart';

class AccountSettingsButtons extends StatelessWidget {
  const AccountSettingsButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildButton(
          text: 'App Settings',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AppSettingsPage(),
              ),
            );
          },
        ),

        const SizedBox(height: 10),

        _buildButton(
          text: 'Account Privacy',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountPrivacyPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the button
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MyColors.color2, width: 2), // Border color
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: MyColors.color2, // Text color
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
          ),
        ),
      ),
    );

  }
}
