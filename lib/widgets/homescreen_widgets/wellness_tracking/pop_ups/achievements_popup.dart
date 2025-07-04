import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../screens/homescreen/wellness_tracking/progress_map_screen.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../controllers/achievements_controller.dart';

class AchievementsPopup extends StatelessWidget {
  const AchievementsPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AchievementsController achievementsController = Get.find<AchievementsController>();

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
                    "Achievements",
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

            // Achievements List (Dynamic)
            Obx(() {
              if (achievementsController.achievements.isEmpty) {
                return const Text(
                  "No achievements yet.\nStart tracking to unlock achievements!",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                );
              }

              return Column(
                children: [
                  for (var achievement in achievementsController.achievements)
                    _buildAchievementTile(
                      title: achievement["title"],
                      icon: achievement["icon"],
                      progress: achievement["progress"],
                      goal: achievement["goal"],
                      unlocked: achievement["unlocked"],
                    ),
                  const SizedBox(height: 20),
                ],
              );
            }),

            // View Achievements Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => const ProgressMapScreen(scrollToIndex: 1)); // Scroll to Achievements Section
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
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: const Text(
                  "View Achievements",
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

  // Helper Method: Build Achievement Item UI
  Widget _buildAchievementTile({
    required String title,
    required String icon,
    required int progress,
    required int goal,
    required bool unlocked,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            unlocked ? "✅" : icon, // Show checkmark if unlocked, otherwise show emoji/icon
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title ($progress/$goal)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: unlocked ? Colors.green : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
