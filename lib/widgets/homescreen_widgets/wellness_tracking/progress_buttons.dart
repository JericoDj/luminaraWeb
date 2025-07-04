import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/achievements_popup.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/daily_mood_popup.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/mood_trends_popup.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/progress_popup.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/stress_level_popup.dart';
import '../../../controllers/MoodController.dart';
import '../../../controllers/progress_controller.dart';
import '../../../controllers/achievements_controller.dart';
import '../../../controllers/stress_controller.dart'; // ✅ Import StressController
import '../../../utils/constants/colors.dart';
import '../../../utils/storage/user_storage.dart';

Widget ProgressButtons(BuildContext context) {
  final ProgressController progressController = Get.put(ProgressController());
  final AchievementsController achievementsController = Get.put(AchievementsController());
  final MoodController moodController = Get.put(MoodController());
  final StressController stressController = Get.put(StressController()); // ✅ Use StressController

  final userProgressController = progressController.userProgressController;

  // ✅ Make sure stress data is loaded
  stressController.fetchStressData(); // This ensures up-to-date average stress

  return Obx(() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircularIconWithLabel(
          context,
          icon: Icons.calendar_today,
          label: 'Check-ins',
          value: '${userProgressController.totalCheckIns.value} days',
          buttonColor: MyColors.color1.withOpacity(0.1),
          iconColor: MyColors.color1,
          borderColor: MyColors.color1,
          displayMode: 'progress',
        ),
        _buildCircularIconWithLabel(
          context,
          icon: Icons.emoji_events,
          label: 'Achievements',
          value: '${achievementsController.achievements.where((a) => a["unlocked"] == true).length} 🏆', // ✅ Use emoji for achievements
          buttonColor: MyColors.color2.withOpacity(0.1),
          borderColor: MyColors.color2,
          iconColor: MyColors.color2,
          displayMode: 'achievement',
        ),
        _buildCircularIconWithLabel(
          context,
          icon: Icons.mood,
          label: 'Mood Trends',
          value: getMoodEmoji(moodController.moodData.isNotEmpty
              ? moodController.moodData.entries.reduce((a, b) => a.value > b.value ? a : b).key
              : "Neutral"), // ✅ Display emoji of the most frequent mood
          buttonColor: Colors.green.shade600.withOpacity(0.1),
          borderColor: MyColors.color1,
          iconColor: MyColors.color1,
          displayMode: 'mood_trends',
        ),
        _buildCircularIconWithLabel(
          context,
          icon: Icons.local_fire_department,
          label: 'Stress Level',
          value: getStressEmoji(stressController.averageStressLevel.value), // ✅ Show emoji based on weekly avg stress
          buttonColor: MyColors.color2.withOpacity(0.1),
          borderColor: MyColors.color2,
          iconColor: MyColors.color2,
          displayMode: 'stress_level',
        ),
      ],
    );
  });
}

Widget _buildCircularIconWithLabel(BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
  required Color borderColor,
  required Color iconColor,
  required Color buttonColor,
  required String displayMode,
}) {
  return GestureDetector(
    onTap: () {
      showTrackingPopup(context, displayMode);
    },
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.5),
            color: buttonColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
        ),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // ✅ Emoji shown as text
        Text(label),
      ],
    ),
  );
}

// ✅ Get Mood Emoji
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
      return "❓"; // Default emoji for unknown mood
  }
}

// ✅ Get Stress Level Emoji
String getStressEmoji(double stressLevel) {
  if (stressLevel < 30) {
    return "🟢"; // Low stress
  } else if (stressLevel >= 30 && stressLevel <= 60) {
    return "🟡"; // Moderate stress
  } else {
    return "🔴"; // High stress
  }
}

// ✅ Trigger the Appropriate Pop-up
void showTrackingPopup(BuildContext context, String mode,
    {String selectedDay = "", String mood = "😊"}) {
  switch (mode) {
    case 'progress':
      showDialog(
        context: context,
        builder: (context) => const ProgressPopup(),
      );
      break;
    case 'mood_trends':
      showDialog(
        context: context,
        builder: (context) => const MoodTrendsPopup(),
      );
      break;
    case 'stress_level':
      getAverageStressLevelMessage().then((message) {
        showDialog(
          context: context,
          builder: (context) => StressLevelPopup(message: message),
        );
      });
      break;
    case 'achievement':
      showDialog(
        context: context,
        builder: (context) => const AchievementsPopup(),
      );
      break;
    case 'daily_mood':
      showDialog(
        context: context,
        builder: (context) => DailyMoodPopup(
          mood: mood,
          selectedDay: selectedDay,
        ),
      );
      break;
    default:
      break;
  }
}

Future<String> getAverageStressLevelMessage() async {
  final userStorage = UserStorage();
  final stressData = userStorage.getStoredStressData();

  double total = 0.0;
  int count = 0;
  final now = DateTime.now();

  for (int i = 0; i < 7; i++) {
    final date = now.subtract(Duration(days: i));
    final key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    double value = stressData[key] ?? 0.0;
    total += value;
    count++;
  }

  final average = total / count;

  if (average < 30) {
    return "Current Stress Level: Low\n\nRecommendation:\n- Keep doing what you're doing!\n- Stay mindful and balanced.";
  } else if (average < 70) {
    return "Current Stress Level: Moderate\n\nRecommendation:\n- Try breathing exercises\n- Take a short walk\n- Listen to relaxing music.";
  } else {
    return "Current Stress Level: High\n\nRecommendation:\n- Consider journaling or talking to a specialist\n- Prioritize rest\n- Reduce screen time and stress triggers\n- *Please consider reaching out to a mental health specialist or professional for further support.*";
  }
}

