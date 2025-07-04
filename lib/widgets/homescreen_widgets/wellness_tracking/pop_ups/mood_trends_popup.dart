import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/MoodController.dart';
import '../../../../screens/homescreen/wellness_tracking/progress_map_screen.dart';
import '../../../../utils/constants/colors.dart';

class MoodTrendsPopup extends StatelessWidget {
  const MoodTrendsPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MoodController moodController = Get.put(MoodController()); // ✅ Use MoodController

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Mood Trends",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ✅ Mood Summary (Dynamically Updated)
            FutureBuilder<String>(
              future: moodController.getAverageMoodLast7Days(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: MyColors.color2,
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text("Unable to fetch average mood");
                }

                String avgMood = snapshot.data!;
                String moodEmoji = moodController.getMoodEmoji(avgMood);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(moodEmoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 10),
                    Text(
                      "Average Mood This Week: $avgMood",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _getMoodRecommendation(avgMood),
                  ],
                );
              },
            ),


            const SizedBox(height: 20),

            // View Details Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Get.to(() => const ProgressMapScreen(scrollToIndex: 2)); // Scroll to Mood Trends
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2, style: BorderStyle.solid, color: MyColors.color1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                child: const Text(
                  "View Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MyColors.color1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ **Returns a Mood-Based Recommendation**
  Widget _getMoodRecommendation(String mood) {
    String recommendation = "";
    switch (mood.toLowerCase()) {
      case "happy":
        recommendation = "Great job! Keep maintaining your positivity.";
        break;
      case "neutral":
        recommendation = "You're doing okay! Try adding some activities that boost happiness.";
        break;
      case "sad":
        recommendation = "It's okay to feel down. Consider talking to a friend or engaging in self-care.";
        break;
      case "angry":
        recommendation = "Try relaxation techniques like deep breathing or a short walk.";
        break;
      case "anxious":
        recommendation = "Practicing mindfulness and deep breathing can help manage anxiety.";
        break;
      default:
        recommendation = "Keep tracking your mood to find patterns and improve your well-being.";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **Maps Mood Strings to Emojis**
  String getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case "happy":
        return "😃";
      case "neutral":
        return "😐";
      case "sad":
        return "😔";
      case "angry":
        return "😡";
      case "anxious":
        return "😰";
      default:
        return "❔"; // Unknown mood
    }
  }
}
