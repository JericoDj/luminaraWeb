import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/moodTrackingController.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/user_progress_controller.dart';
import '../../utils/constants/colors.dart';

void showMoodDialog(BuildContext context) {
  final MoodTrackingController moodController = Get.put(MoodTrackingController());
  final UserProgressController userProgressController = Get.put(UserProgressController());
  final HomeController homeController = Get.find<HomeController>(); // ✅ Ensure HomeController is found

  showDialog(
    context: context,
    barrierDismissible: false, // Prevents accidental dismissal
    builder: (dialogContext) {
      double _stressLevel = 50.0;
      String _selectedMood = "";
      String _moodTemp = "";

      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with Exit Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "How are you feeling today?",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 24),
                        onPressed: () async {
                          // ✅ Always refresh mood data before closing
                          await _saveMoodAndClose(dialogContext, _moodTemp, _stressLevel, moodController, userProgressController, homeController, forceFetch: true);
                        },
                      ),
                    ],
                  ),
                ),

                // Mood Emojis
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMoodEmoji(dialogContext, "😃", "Happy", _moodTemp, () {
                        setState(() => _moodTemp = "Happy");
                      }),
                      _buildMoodEmoji(dialogContext, "😐", "Neutral", _moodTemp, () {
                        setState(() => _moodTemp = "Neutral");
                      }),
                      _buildMoodEmoji(dialogContext, "😔", "Sad", _moodTemp, () {
                        setState(() => _moodTemp = "Sad");
                      }),
                      _buildMoodEmoji(dialogContext, "😡", "Angry", _moodTemp, () {
                        setState(() => _moodTemp = "Angry");
                      }),
                      _buildMoodEmoji(dialogContext, "😰", "Anxious", _moodTemp, () {
                        setState(() => _moodTemp = "Anxious");
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Stress Level Section
                const Text("Stress Level", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Slider(
                      activeColor: MyColors.color2,
                      value: _stressLevel,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: '${_stressLevel.toStringAsFixed(0)}%',
                      onChanged: (double value) {
                        setState(() {
                          _stressLevel = value;
                        });
                      },
                    ),
                    Text(
                      '${_stressLevel.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Confirm Button
                GestureDetector(
                  onTap: () async {
                    await _saveMoodAndClose(dialogContext, _moodTemp, _stressLevel, moodController, userProgressController, homeController, forceFetch: false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: MyColors.color1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(() => moodController.isSaving.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
    },
  );
}

// ✅ Function to Save Mood and Close Dialog
Future<void> _saveMoodAndClose(
    BuildContext dialogContext,
    String mood,
    double stressLevel,
    MoodTrackingController moodController,
    UserProgressController userProgressController,
    HomeController homeController,
    {bool forceFetch = false}) async {

  if (mood.isNotEmpty) {
    await moodController.saveMoodTracking(mood, stressLevel.toInt());

    // ✅ Fetch latest daily check-ins
    await userProgressController.fetchUserCheckIns();

    // ✅ Refresh HomeScreen
    homeController.update();

    ScaffoldMessenger.of(dialogContext).showSnackBar(
      SnackBar(
        content: Text("You selected: $mood with Stress Level: ${stressLevel.toStringAsFixed(0)}%"),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ✅ Always fetch mood data when closing
  if (forceFetch || mood.isNotEmpty) {
    await moodController.fetchUserMoodDataForCurrentWeek();
  }

  Navigator.pop(dialogContext); // ✅ Close dialog after saving or refreshing
}

// Mood Emoji Selection
Widget _buildMoodEmoji(BuildContext dialogContext, String emoji, String mood, String selectedMood, VoidCallback onTap) {
  bool isSelected = selectedMood == mood;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isSelected ? MyColors.color2.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? MyColors.color2 : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: 30, color: isSelected ? Colors.black : Colors.black87),
          ),
          const SizedBox(height: 5),
          Text(
            mood,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.black87),
          ),
        ],
      ),
    ),
  );
}
