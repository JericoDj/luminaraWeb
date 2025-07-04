import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../screens/homescreen/wellness_tracking/progress_map_screen.dart';
import '../../../../utils/constants/colors.dart';

class DailyMoodPopup extends StatelessWidget {
  final String selectedDay;
  final String mood;

  const DailyMoodPopup({
    Key? key,
    required this.selectedDay,
    required this.mood,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mood for $selectedDay",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Content
            Center(
              child: Column(
                children: [
                  Text(
                    "$mood",
                    style: const TextStyle(fontSize: 30),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "$selectedDay Mood",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),


            // View Details Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => ProgressMapScreen(
                  scrollToIndex: 2,
                  selectedDay: selectedDay, // Ensure this is in the correct format (e.g., yyyy-MM-dd)
                ));
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    style: BorderStyle.solid,
                    color: MyColors.color1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: const Text(
                  "View Details",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyColors.color1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}