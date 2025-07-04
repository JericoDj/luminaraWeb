import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../screens/homescreen/wellness_tracking/progress_map_screen.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../controllers/user_progress_controller.dart'; // Import controller

class ProgressPopup extends StatelessWidget {
  const ProgressPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProgressController userProgressController = Get.find<UserProgressController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "User Progress",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 24),
                    onPressed: () => Navigator.pop(context), // Close dialog
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Dynamic Content
            Obx(() {
              final int checkIns = userProgressController.totalCheckIns.value;
              final int streak = userProgressController.streak.value;

              return Column(
                children: [
                  Text(
                    "You have checked in $checkIns times\n this month!\n"
                        "Streak: $streak days in a row.\n"
                        "Keep up the great work!",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),

            // View Progress Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => const ProgressMapScreen(scrollToIndex: 0)); // Scroll to User Progress (Index 0)
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    style: BorderStyle.solid,
                    color: MyColors.color1, // Border color
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                child: const Text(
                  "View Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyColors.color1, // Text color matches the border
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
