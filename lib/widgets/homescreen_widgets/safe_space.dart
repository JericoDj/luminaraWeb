import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llps_mental_app/utils/constants/colors.dart';

import '../../screens/homescreen/safe_space/safetalk.dart';


class SafeSpaceCard extends StatelessWidget {
  const SafeSpaceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to a new screen when clicked
        Get.to(() => const SafeTalk());
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // Adjust width here
        margin: const EdgeInsets.symmetric(horizontal: 50), // Optional: Add horizontal margin
        decoration: BoxDecoration(
          color: MyColors.color1.withOpacity(.9),
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
            backgroundColor: Colors.white.withOpacity(.7),
            child: const Icon(
              Icons.support_agent,
              color: MyColors.color1,
              size: 30,
            ),
          ),
          title: const Text(
            "24/7 Safe Space",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: const Text(
            "Reach out to us anytime, anywhere.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
