import 'package:flutter/material.dart';

import '../../widgets/accounts_screen/accounts_settings_buttons.dart';
import '../../widgets/accounts_screen/consultation_status_widget.dart';
import '../../widgets/accounts_screen/contact_support_section.dart';
import '../../widgets/accounts_screen/logout_button.dart';
import '../../widgets/accounts_screen/user_account_section.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.grey[100],
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const UserAccountSection(),
                    const SizedBox(height: 20),
                    ConsultationStatusTabsWidget(),
                    const SizedBox(height: 20),
                    const AccountSettingsButtons(),
                    const SizedBox(height: 20),
                    const ContactSupportSection(),
                    const SizedBox(height: 20),
                    const LogoutButton(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
