import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llps_mental_app/utils/constants/colors.dart';

import '../../screens/homescreen/consultation_touchpoint/consultation_screen.dart';

class ConsultationTouchpointCard extends StatelessWidget {
  const ConsultationTouchpointCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the next screen using GetX
        Get.to(() => const ConsultationScreen());
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // Adjust width here
        margin: const EdgeInsets.symmetric(horizontal: 50), // Optional: Add horizontal margin
        decoration: BoxDecoration(

          color: MyColors.color1.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: MyColors.color1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16,0,16,0),
          leading: CircleAvatar(
            backgroundColor: MyColors.white.withOpacity(0.7),
            child: const Icon(
              Icons.medical_services_outlined,
              color: MyColors.color1,
              size: 30,
            ),
          ),
          title: const Text(
            "Safe Space",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: const Text(
            "Connect with mental health experts.",
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
