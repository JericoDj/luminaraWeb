import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/homescreen/safe_space/safetalk.dart';
import '../../utils/constants/colors.dart';

class SafeTalkButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => SafeTalk()),
      child: Container(
        width: 200,
        padding: EdgeInsets.all(2), // Creates a thick border effect
        decoration: BoxDecoration(
          color: MyColors.color2, // Outer border color
          borderRadius: BorderRadius.circular(5),

        ),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
             ),
          padding:EdgeInsets.all(2),

          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: MyColors.color2, // Inner background color

            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 5),
                Text(
                  'Safe Talk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                Text(
                  'Connect with a specialist',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '24/7 Available',
                  style: TextStyle(
                    fontSize:16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
