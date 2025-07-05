import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../utils/storage/user_storage.dart';
import 'package:intl/intl.dart';

class MoodController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStorage _storage = UserStorage();

  var selectedPeriod = "Weekly".obs;
  var moodData = <String, int>{}.obs;
  var dailyMoods = <String, String>{}.obs;

  final List<String> _allMoods = ["Happy", "Neutral", "Sad", "Angry", "Anxious"];

  @override
  void onInit() {
    super.onInit();
    _loadMoodsFromStorage();
  }

  // 🆕 Get dominant mood calculation
  String getDominantMood() {
    final counts = getMoodCounts();
    if (counts.isEmpty) return "No data";

    String dominant = "";
    int maxCount = 0;

    counts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = mood;
      }
    });

    return dominant.isNotEmpty ? dominant : "Neutral";
  }




  /// ✅ **Save Mood & Stress Level to Firestore**
  Future<void> saveMoodTracking(String mood, int stressLevel) async {
    String? uid = _storage.getUid(); // Get current user UID from local storage

    if (uid == null) {
      Get.snackbar("Error", "User ID not found. Please log in again.");
      return;
    }

    String todayDate = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    String moodEmoji = getMoodEmoji(mood); // Convert mood to emoji




    try {
      await _firestore.collection("users").doc(uid)
          .collection("moodTracking")
          .doc(todayDate)
          .set({
        "mood": mood,
        "moodEmoji": moodEmoji, // Store the emoji representation in Firestore
        "stressLevel": stressLevel,
        "timestamp": Timestamp.now(),
      });

      // Update local state to reflect the new mood immediately
      dailyMoods[todayDate] = moodEmoji; // ✅ Store the emoji instead of text
      _storage.saveMoods({todayDate: moodEmoji}); // Save to local storage

      Get.snackbar("Success", "Mood tracking saved successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to save mood tracking: $e");
    }
  }

  // ✅ Convert Mood Text to Emoji
  String getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) { // Convert to lowercase for consistency
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
        return "◽️"; // Default emoji for missing data
    }
  }


  // ✅ **Get Weekly Moods (latest 7 days)**
  // ✅ **Get Weekly Moods (latest 7 days)**
  Future<Map<String?, String?>> getWeeklyMoods() async {
    print("running");
    String? uid = _storage.getUid();
    if (uid == null) return {};

    // Fetch moods for the last 7 days
    DateTime now = DateTime.now();
    List<String> missingDates = [];

    // Get the 7 most recent dates
    for (int i = 0; i < 7; i++) {
      String date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      if (!dailyMoods.containsKey(date)) {
        missingDates.add(date);
      }
    }

    // If there are missing dates, fetch them from Firestore
    if (missingDates.isNotEmpty) {
      print("🔍 Fetching missing moods for: $missingDates");

      try {
        Map<String, String> newMoods = {};

        for (String date in missingDates) {
          DocumentSnapshot<Map<String, dynamic>> moodDoc = await _firestore
              .collection("users")
              .doc(uid)
              .collection("moodTracking")
              .doc(date)
              .get();

          String mood = "⬜"; // Default to empty mood
          if (moodDoc.exists && moodDoc.data() != null) {
            // Safely retrieve the mood value and cast it as a String
            mood = moodDoc.data()!["mood"]?.toString() ?? "⬜"; // Ensure it's a String
          }

          newMoods[date] = mood;
          print("📆 Date: $date | Mood: $mood");
        }

        // Save the fetched moods to local storage
        dailyMoods.addAll(newMoods);
        _storage.saveMoods(newMoods);  // ✅ Save to local storage
        print("✅ Fetched and stored new moods: $newMoods");
        return newMoods;
      } catch (e) {

        return {};
      }
    } else {
      print("✅ All weekly moods are already cached in local storage.");
      return dailyMoods;
    }
  }


  // ✅ Calculate average mood for the last 7 days
  // ✅ Calculate most frequent mood for the last 7 days (with local storage priority)
  Future<String> getAverageMoodLast7Days() async {
    String? uid = _storage.getUid();
    if (uid == null) return "No User";

    DateTime now = DateTime.now();
    Map<String, int> moodCounts = {
      "happy": 0,
      "neutral": 0,
      "anxious": 0,
      "angry": 0,
      "sad": 0,
    };

    String latestMood = "neutral";  // Default latest mood
    DateTime latestTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

    // ✅ Step 1: Load moods from local storage
    Map<String, String> storedMoods = _storage.getStoredMoods();
    List<String> missingDates = [];

    // ✅ Step 2: Check today's mood in local storage & track missing dates
    for (int i = 0; i < 7; i++) {
      String date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));

      if (storedMoods.containsKey(date)) {
        String mood = storedMoods[date]!;
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
        latestMood = mood;  // Treat as the latest mood if stored locally
      } else {
        missingDates.add(date);  // Identify dates missing in local storage
      }
    }

    // ✅ Step 3: Fetch missing moods from Firestore if needed
    if (missingDates.isNotEmpty) {
      print("🔍 Fetching missing moods for: $missingDates");

      try {
        Map<String, String> newMoods = {};

        for (String date in missingDates) {
          DocumentSnapshot<Map<String, dynamic>> moodDoc = await _firestore
              .collection("users")
              .doc(uid)
              .collection("moodTracking")
              .doc(date)
              .get();

          if (moodDoc.exists && moodDoc.data() != null) {
            String mood = moodDoc.data()!["mood"]?.toString().toLowerCase() ?? "neutral";
            Timestamp? timestamp = moodDoc.data()?['timestamp'];

            // ✅ Track frequency
            if (moodCounts.containsKey(mood)) {
              moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
            }

            // ✅ Track the most recent mood
            if (timestamp != null && timestamp.toDate().isAfter(latestTimestamp)) {
              latestMood = mood;
              latestTimestamp = timestamp.toDate();
            }

            newMoods[date] = mood;
          }
        }

        // ✅ Save fetched moods to local storage
        _storage.saveMoods(newMoods);

      } catch (e) {
        print("🔥 Error fetching missing moods from Firestore: $e");
      }
    }

    // ✅ Step 4: Determine most frequent mood
    if (moodCounts.values.every((count) => count == 0)) {
      return "No mood data";
    }

    String mostFrequentMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // ✅ Step 5: Handle ties - if tied, use the latest mood
    List<String> tiedMoods = moodCounts.entries
        .where((entry) => entry.value == moodCounts[mostFrequentMood])
        .map((entry) => entry.key)
        .toList();

    if (tiedMoods.length > 1) {
      return latestMood;
    } else {
      return mostFrequentMood;
    }
  }








  /// ✅ **Updates Selected Period & Fetches Data**
  void updatePeriod(String period) {
    selectedPeriod.value = period;
    fetchMissingMoods();
  }

  /// ✅ **Load moods from local storage first, then fetch missing data**
  void _loadMoodsFromStorage() {
    Map<String, String>? storedMoods = _storage.getStoredMoods();
    if (storedMoods != null && storedMoods.isNotEmpty) {
      dailyMoods.assignAll(storedMoods);
      print("🔄 Loaded moods from storage: $storedMoods");
    }
    fetchMissingMoods();  // Fetch only missing data
  }

  /// ✅ **Fetch mood counts for the latest X days based on period**
  Map<String, int> getMoodCounts() {
    int daysCount = getDaysFromPeriod(selectedPeriod.value);
    Map<String, int> moodCounts = {for (var mood in _allMoods) mood: 0};

    for (var moodEntry in getLatestMoods(daysCount)) {
      String mood = moodEntry["mood"] ?? "⬜";
      if (moodCounts.containsKey(mood)) {
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      }
    }

    print("📊 Mood Counts for ${selectedPeriod.value}: $moodCounts");
    return moodCounts;
  }

  /// ✅ **Fetch moods dynamically based on period**
  List<Map<String, String>> getLatestMoods(int daysCount) {
    List<Map<String, String>> days = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < daysCount; i++) {
      DateTime day = now.subtract(Duration(days: i));
      String formattedDay = DateFormat('EEE').format(day);
      String formattedDate = DateFormat('yyyy-MM-dd').format(day);

      days.add({
        "day": formattedDay,
        "date": formattedDate,
        "mood": dailyMoods[formattedDate] ?? "⬜",
      });
    }
    print("📆 Latest ${selectedPeriod.value} moods: $days");
    return days.reversed.toList();
  }

  /// ✅ **Fetch missing moods from Firestore**
  Future<void> fetchMissingMoods() async {
    String? uid = _storage.getUid();
    if (uid == null) return;

    List<String> neededDates = _getNeededDates();  // ✅ Get missing dates based on selected period

    if (neededDates.isEmpty) {
      print("✅ All moods are already cached.");
      return;
    }

    print("🔍 Fetching missing moods for: ${selectedPeriod.value}");
    print("🗓️ Needed Dates: $neededDates");

    try {
      Map<String, String> newMoods = {};

      for (String date in neededDates) {
        DocumentSnapshot<Map<String, dynamic>> moodDoc = await _firestore
            .collection("users")
            .doc(uid)
            .collection("moodTracking")
            .doc(date)
            .get();

        String mood = "⬜";
        if (moodDoc.exists && moodDoc.data() != null) {
          mood = moodDoc.data()!["mood"] ?? "⬜";
        }

        newMoods[date] = mood;
        print("📆 Date: $date | Mood: $mood");
      }

      dailyMoods.addAll(newMoods);
      _storage.saveMoods(newMoods);  // ✅ Save fetched moods to local storage
      print("✅ Fetched and stored new moods: $newMoods");
    } catch (e) {
      print("❌ Firestore Error: $e");
    }
  }

  /// ✅ **Determine how many days to fetch based on selected period**
  int getDaysFromPeriod(String period) {
    switch (period) {
      case "Weekly":
        return 7;
      case "Monthly":
        return 30;
      case "Quarterly":
        return 90;
      case "Semi-Annual":
        return 180;
      case "Annual":
        return 365;
      default:
        return 7;
    }
  }


  /// ✅ **Determine which dates are missing**
  List<String> _getNeededDates() {
    List<String> missingDates = [];
    int daysToFetch = getDaysFromPeriod(selectedPeriod.value);
    DateTime now = DateTime.now();

    for (int i = 0; i < daysToFetch; i++) {
      String date = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: i)));
      if (!dailyMoods.containsKey(date)) {
        missingDates.add(date);
      }
    }
    return missingDates;
  }

  /// ✅ **Clear moods from GetStorage (for logout)**
  void clearStoredMoods() {
    _storage.clearMoods();
    dailyMoods.clear();
    print("🗑️ Cleared stored moods.");
  }
}


