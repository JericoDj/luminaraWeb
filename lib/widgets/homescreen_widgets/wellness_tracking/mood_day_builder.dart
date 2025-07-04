import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/daily_mood_popup.dart';

import '../../../controllers/moodTrackingController.dart';

final MoodTrackingController moodController = Get.put(MoodTrackingController()); // Inject Controller

Widget buildMoodSection(BuildContext context) {
  // Fetch the mood data for the current week whenever the section is built
  moodController.fetchUserMoodDataForCurrentWeek();

  return Obx(() {
    final moods = moodController.userMoods;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: moods.keys.map((day) {
          return buildMoodDay(day, moods[day] ?? "◽️", context);  // Default to neutral if no mood data
        }).toList(),
      ),
    );
  });
}

Widget buildMoodDay(String day, String emoji, BuildContext context) {
  return GestureDetector(
    onTap: () {
      // Show the popup with the daily mood when the user taps on a day
      showDialog(
        context: context,
        builder: (context) => DailyMoodPopup(
          mood: emoji,
          selectedDay: day,
        ),
      );
    },
    child: Column(
      children: [
        Text(
          day,
          style: GoogleFonts.archivo(
              color: Colors.green.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
        ),
        const SizedBox(height: 5),
        Text(emoji, style: const TextStyle(fontSize: 24)), // Display the emoji for the day
      ],
    ),
  );
}
