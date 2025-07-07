import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            context.push('/app-settings');
          },
        ),

        const SizedBox(height: 10),

        _buildButton(
          text: 'Account Privacy',
          onPressed: () {
            context.push('/account-privacy');
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MyColors.color2, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: MyColors.color2,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
