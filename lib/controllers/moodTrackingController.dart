import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../utils/storage/user_storage.dart';
import 'package:get_storage/get_storage.dart';

class MoodTrackingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStorage _storage = UserStorage();
  final GetStorage _localStorage = GetStorage();

  var isSaving = false.obs; // Loading state
  var userMoods = <String, String>{}.obs; // Map for storing moods (Day -> Emoji)

  // Save Mood & Stress Level to Firestore
  Future<void> saveMoodTracking(String mood, int stressLevel) async {
    String? uid = _storage.getUid();

    if (uid == null) {
      Get.snackbar("Error", "User ID not found. Please log in again.");
      return;
    }

    String todayDate = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    String moodEmoji = getMoodEmoji(mood); // Convert mood to emoji

    isSaving.value = true; // Show loading indicator

    try {
      await _firestore.collection("users").doc(uid)
          .collection("moodTracking")
          .doc(todayDate)
          .set({
        "mood": mood,
        "moodEmoji": moodEmoji,
        "stressLevel": stressLevel,
        "timestamp": Timestamp.now(),
      });

      // ✅ Update local state to reflect the new mood immediately
      userMoods[getDayOfWeek(todayDate)] = moodEmoji;

      // ✅ Store the updated mood data in local storage
      _localStorage.write("userMoods", userMoods);

      // ✅ Fetch latest moods again to ensure UI consistency
      await fetchUserMoodDataForCurrentWeek();

      Get.snackbar("Success", "Mood tracking saved successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to save mood tracking: $e");
    } finally {
      isSaving.value = false; // Hide loading indicator
    }
  }


  Future<void> fetchUserMoodDataForCurrentWeek() async {
    String? uid = _storage.getUid();
    if (uid == null) return;



    try {
      DateTime now = DateTime.now();

      // Dynamically calculate the number of days to fetch based on the current day.
      int daysToFetch;
      if (now.weekday == DateTime.monday) {
        daysToFetch = 0;
      } else if (now.weekday == DateTime.tuesday) {
        daysToFetch = 1;
      } else if (now.weekday == DateTime.wednesday) {
        daysToFetch = 2;
      } else if (now.weekday == DateTime.thursday) {
        daysToFetch = 3;
      } else if (now.weekday == DateTime.friday) {
        daysToFetch = 4;
      } else if (now.weekday == DateTime.saturday) {
        daysToFetch = 5;
      } else if (now.weekday == DateTime.sunday) {
        daysToFetch = 6;
      } else {
        daysToFetch = 3;
      }

      DateTime startOfPeriod = now.subtract(Duration(days: daysToFetch)); // Dynamic number of days
      print("DEBUG: Fetching moods from ${startOfPeriod.toIso8601String()} to ${now.toIso8601String()}");

      var snapshot = await _firestore
          .collection("users")
          .doc(uid)
          .collection("moodTracking")
          .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfPeriod))
          .where("timestamp", isLessThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy("timestamp", descending: true)
          .get(); // Fetch moods for the last `daysToFetch` days

      print("Snapshot size: ${snapshot.size}");

      // If no data is found, notify the user
      if (snapshot.docs.isEmpty) {
        Get.snackbar("No Data", "No mood data found for this period.");
        return;
      }

      var newMoods = <String, String>{};

      for (var doc in snapshot.docs) {
        String date = doc.id; // YYYY-MM-DD format
        String dayOfWeek = getDayOfWeek(date); // Convert to Mon-Sun
        String mood = doc["mood"] ?? " ";
        String moodEmoji = getMoodEmoji(mood); // Convert mood to emoji

        newMoods[dayOfWeek] = moodEmoji; // Store the emoji for the day

        // Debugging print statement for each mood fetched
        print("DEBUG: Retrieved Mood for $dayOfWeek -> $mood ($moodEmoji)");
      }

      // Update the reactive userMoods variable with the new data
      userMoods.assignAll(newMoods);
      print("DEBUG: Updated Weekly Mood Data -> $userMoods");

      // Store the updated data in local storage for future use
      _localStorage.write("userMoods", userMoods);

    } catch (e) {
      print("DEBUG: Error Fetching Weekly Mood Data -> $e");
      Get.snackbar("Error", "Failed to fetch mood data: $e");
    }
  }

  // Convert Date (YYYY-MM-DD) to Weekday Name (Mon-Sun)
  String getDayOfWeek(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][parsedDate.weekday % 7];
    } catch (e) {
      return "Unknown";
    }
  }

  // Convert Mood Text to Emoji
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
        return "⬜"; // Default emoji for missing data
    }
  }
}
