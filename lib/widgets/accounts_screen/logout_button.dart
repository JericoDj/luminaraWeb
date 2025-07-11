import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/login_controller/loginController.dart';
import '../../utils/constants/colors.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: () {
          // 🔄 Access LoginController and call logout
          final loginController = Provider.of<LoginController>(context, listen: false);
          loginController.logout(context);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: MyColors.color2, width: 2.5),
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
        ),
        child: Text(
          'Log Out',
          style: TextStyle(
            color: MyColors.color2,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
