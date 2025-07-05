import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../utils/storage/user_storage.dart';
import 'user_progress_controller.dart'; // Import UserProgressController

class AchievementsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStorage _storage = UserStorage();

  var achievements = <Map<String, dynamic>>[].obs;
  final UserProgressController _progressController = Get.find<
      UserProgressController>();

  bool _hasFetched = false; // ✅ Flag to ensure we only fetch once

  @override
  void onInit() {
    super.onInit();
    if (!_hasFetched) {
      fetchUserAchievements();
      _hasFetched = true; // ✅ Prevent multiple fetches
    }
  }

  Future<void> fetchUserAchievements() async {
    String? uid = _storage.getUid();
    if (uid == null) {
      print("❌ Error: UID is null");
      return;
    }

    try {
      var achievementsRef = _firestore.collection("users").doc(uid).collection(
          "achievements");
      var snapshot = await achievementsRef.get();

      if (snapshot.docs.isEmpty) {
        print("⚠️ No achievements found. Creating default achievements...");
        await _createDefaultAchievements(uid);
        snapshot = await achievementsRef.get();
      }

      List<Map<String, dynamic>> fetchedAchievements = snapshot.docs.map((doc) {
        var data = doc.data();
        return {
          "id": doc.id,
          "title": data["title"],
          "icon": data["icon"] ?? "star",
          "progress": data["progress"] ?? 0,
          "goal": data["goal"] ?? 0,
          "unlocked": data["unlocked"] ?? false,
        };
      }).toList();

      achievements.assignAll(fetchedAchievements); // ✅ Store data in memory
      print("✅ Achievements Loaded: ${achievements.length}");

      _updateAchievementsProgress(uid);
    } catch (e) {
      print("❌ Firestore Fetch Error: $e");
      Get.snackbar("Error", "Failed to fetch achievements: $e");
    }
  }

  /// **Creates the Default Achievements for a New User**
  Future<void> _createDefaultAchievements(String uid) async {
    List<Map<String, dynamic>> defaultAchievements = [
      {
        "title": "3-Day Streak",
        "icon": "🔥",
        "progress": 0,
        "goal": 3,
        "unlocked": false
      },
      {
        "title": "7-Day Streak",
        "icon": "🔥",
        "progress": 0,
        "goal": 7,
        "unlocked": false
      },
      {
        "title": "15-Day Streak",
        "icon": "🔥",
        "progress": 0,
        "goal": 15,
        "unlocked": false
      },
      {
        "title": "1 Month Streak",
        "icon": "🔥",
        "progress": 0,
        "goal": 30,
        "unlocked": false
      },
      {
        "title": "90-Day Streak",
        "icon": "🔥",
        "progress": 0,
        "goal": 90,
        "unlocked": false
      },
      {
        "title": "First Check-in",
        "icon": "✔️",
        "progress": 0,
        "goal": 1,
        "unlocked": false
      },
      {
        "title": "10 Check-ins",
        "icon": "✔️",
        "progress": 0,
        "goal": 10,
        "unlocked": false
      },
      {
        "title": "50 Check-ins",
        "icon": "✔️",
        "progress": 0,
        "goal": 50,
        "unlocked": false
      },
      {
        "title": "100 Check-ins",
        "icon": "⭐",
        "progress": 0,
        "goal": 100,
        "unlocked": false
      },
      {
        "title": "365 Check-ins",
        "icon": "🏆",
        "progress": 0,
        "goal": 365,
        "unlocked": false
      },
    ];

    var achievementsRef = _firestore.collection("users").doc(uid).collection(
        "achievements");

    for (var achievement in defaultAchievements) {
      await achievementsRef.add(achievement);
    }

    print("🎉 Default Achievements Created Successfully!");
  }

  /// **Update Achievements Based on Progress Efficiently**
  /// **Update Achievements Based on Progress Efficiently**
  Future<void> _updateAchievementsProgress(String uid) async {
    var achievementsRef = _firestore.collection("users").doc(uid).collection(
        "achievements");

    for (var achievement in achievements) {
      String title = achievement["title"];
      int newProgress = 0;

      if (title.contains("Streak")) {
        newProgress = _progressController.streak.value;
      } else if (title.contains("Check-in")) {
        newProgress = _progressController.totalCheckIns.value;
      }

      // ✅ Prevent Updating Already Unlocked Achievements
      if (achievement["unlocked"]) {
        print("✅ $title is already unlocked. Skipping update.");
        continue;
      }

      // ✅ Ensure Progress Never Exceeds Goal
      newProgress =
      newProgress > achievement["goal"] ? achievement["goal"] : newProgress;

      if (newProgress > achievement["progress"]) {
        print("🔄 Updating $title with progress: $newProgress");

        await achievementsRef.doc(achievement["id"]).update({
          "progress": newProgress,
          "unlocked": newProgress >= achievement["goal"],
        });

        // ✅ Update the local cache to reflect the change immediately
        achievement["progress"] = newProgress;
        achievement["unlocked"] = newProgress >= achievement["goal"];
      }
    }

    achievements
        .refresh(); // ✅ Ensures UI updates without another Firestore fetch
  }
}
