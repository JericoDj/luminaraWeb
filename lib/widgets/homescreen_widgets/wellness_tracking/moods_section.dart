import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/progress_buttons.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/wellness_map.dart';
import '../../../controllers/moodTrackingController.dart';

final MoodTrackingController moodController = Get.put(MoodTrackingController()); // Inject Controller

Widget buildMoodSection(BuildContext context) {
  return Obx(() {
    final moods = moodController.userMoods;

    print("DEBUG: Fetched moods inside Obx -> $moods"); // Debugging

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
        children: List.generate(7, (index) {
          String day = getDayOfWeekFromIndex(index); // Convert index to weekday
          print("DEBUG: Building mood for day -> $day");

          String emoji = moods[day] ?? "◽️";
          print("DEBUG: Emoji for $day -> $emoji");

          return buildMoodDay(day, emoji, context, index + 1);
        }),
      ),
    );
  });
}


String getDayOfWeekFromIndex(int index) {
  // This method maps the index to the day (0 -> Mon, 1 -> Tue, ..., 6 -> Sun)
  switch (index) {
    case 0:
      return "Mon";
    case 1:
      return "Tue";
    case 2:
      return "Wed";
    case 3:
      return "Thu";
    case 4:
      return "Fri";
    case 5:
      return "Sat";
    case 6:
      return "Sun";
    default:
      return "Unknown";
  }
}

Widget buildMoodDay(String day, String emoji, BuildContext context, int dayNumber) {
  // Debugging print statement for each emoji
  print("DEBUG: Building mood day for $day with emoji $emoji");

  return GestureDetector(
    onTap: () {
        showTrackingPopup(context, 'daily_mood', selectedDay: day, mood: emoji);
    },
    child: Column(
      children: [
        // Display day and day number (Mon -> 1, Tue -> 2, etc.)
        Text(
          '$day ',
          style: GoogleFonts.archivo(color: Colors.green.shade600, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(emoji, style: const TextStyle(fontSize: 24)),
      ],
    ),
  );
}

