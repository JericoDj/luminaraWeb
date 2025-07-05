import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../utils/storage/user_storage.dart';

class UserProgressController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStorage _storage = UserStorage(); // Local storage for UID

  var totalCheckIns = 0.obs; // Total number of check-ins
  var streak = 0.obs; // Consecutive check-ins streak

  @override
  void onInit() {
    super.onInit();
    fetchUserCheckIns(); // Fetch data when the controller initializes
  }

  Future<void> fetchUserCheckIns() async {
    String? uid = _storage.getUid();
    if (uid == null) {
      print("❌ Error: UID is null. Cannot fetch check-ins.");
      return;
    }

    try {
      print("📡 Fetching check-ins for UID: $uid...");

      var snapshot = await _firestore
          .collection("users")
          .doc(uid)
          .collection("moodTracking")
          .get(); // Fetch all documents

      if (snapshot.docs.isEmpty) {
        print("⚠️ No check-ins found for user: $uid");
        totalCheckIns.value = 0;
        streak.value = 0;
        return;
      }

      // Since document IDs are the check-in dates, count the number of documents
      List<String> checkInDates = snapshot.docs.map((doc) => doc.id).toList();

      // DEBUG: Print the fetched check-ins
      print("✅ Firestore Check-ins Fetched: ${checkInDates.length}");
      for (var doc in snapshot.docs) {
        print("📝 ${doc.id}: ${doc.data()}");
      }

      totalCheckIns.value = checkInDates.length; // Update total check-ins
      calculateStreak(checkInDates); // Calculate streak

      print("📊 Updated Total Check-ins: ${totalCheckIns.value}, Streak: ${streak.value}");
    } catch (e) {
      print("❌ Firestore Fetch Error: $e");
      Get.snackbar("Error", "Failed to fetch check-ins: $e");
    }
  }

  void calculateStreak(List<String> checkInDates) {
    if (checkInDates.isEmpty) {
      streak.value = 0;
      return;
    }

    checkInDates.sort((a, b) => b.compareTo(a)); // Sort in descending order
    DateTime latestDate = DateTime.parse(checkInDates.first);
    int currentStreak = 1;

    for (int i = 1; i < checkInDates.length; i++) {
      DateTime prevDate = DateTime.parse(checkInDates[i]);
      DateTime expectedDate = latestDate.subtract(Duration(days: 1));

      if (prevDate.year == expectedDate.year &&
          prevDate.month == expectedDate.month &&
          prevDate.day == expectedDate.day) {
        currentStreak++;
        latestDate = prevDate;
      } else {
        break; // Streak broken
      }
    }

    streak.value = currentStreak;
    print("🔥 Current Streak: ${streak.value} days");
  }
}
