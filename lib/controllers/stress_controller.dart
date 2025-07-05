import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../utils/storage/user_storage.dart';

class StressController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserStorage _storage = UserStorage();

  var selectedPeriod = "Weekly".obs; // Default period
  var stressData = <String, double>{"Low": 40, "Moderate": 35, "High": 25}.obs; // Stress distribution
  var averageStressLevel = 0.0.obs; // Average stress level of the user

  @override
  void onInit() {
    super.onInit();
    fetchStressData(); // Fetch stress data when initialized
  }

  // ✅ Fetch Stress Data from Firestore
  Future<void> fetchStressData() async {
    String? uid = _storage.getUid();
    if (uid == null) {
      print("❌ Error: UID is null");
      return;
    }

    try {
      // Get stored stress data from local storage
      Map<String, double> storedStressData = _storage.getStoredStressData();

      // Get the start date based on the selected period
      DateTime startDate = _getStartDateForPeriod();
      DateTime endDate = DateTime.now();

      // Generate date range for the selected period
      List<String> dateRange = _getDateRangeForPeriod(startDate, endDate);

      // Identify missing dates not in local storage
      List<String> missingDates = dateRange.where((date) => !storedStressData.containsKey(date)).toList();

      // Fetch missing dates from Firestore
      if (missingDates.isNotEmpty) {
        var stressRef = _firestore.collection("users").doc(uid).collection("moodTracking");
        Map<String, double> fetchedData = {};

        for (String date in missingDates) {
          DocumentSnapshot doc = await stressRef.doc(date).get();
          if (doc.exists) {
            // Safely cast doc.data() to Map<String, dynamic>
            var data = doc.data() as Map<String, dynamic>;

            // Access stressLevel using the map
            int stress = (data["stressLevel"] ?? 50).toInt();
            fetchedData[date] = stress.toDouble();
          }
        }

        // Save fetched data to local storage
        _storage.saveStressData(fetchedData);
      }

      // Get updated data from local storage (including newly fetched)
      Map<String, double> updatedStoredData = _storage.getStoredStressData();

      // Collect stress levels for the current period
      List<int> stressLevels = [];
      for (String date in dateRange) {
        if (updatedStoredData.containsKey(date)) {
          stressLevels.add(updatedStoredData[date]!.toInt());
        }
      }

      if (stressLevels.isEmpty) {
        print("⚠️ No stress data found for the selected period.");
        return;
      }

      // Update calculations
      calculateStressDistribution(stressLevels);
      calculateAverageStress(stressLevels);
    } catch (e) {
      print("❌ Error fetching stress data: $e");
    }
  }

  // ✅ Update Period Selection and Refresh Data
  void updatePeriod(String newPeriod) {
    selectedPeriod.value = newPeriod;
    fetchStressData(); // Refresh stress data
  }

  // ✅ Get Start Date Based on Selected Period
  DateTime _getStartDateForPeriod() {
    DateTime now = DateTime.now();
    switch (selectedPeriod.value) {
      case "Weekly":
        return now.subtract(const Duration(days: 6)); // 7 days including today
      case "Monthly":
        return DateTime(now.year, now.month - 1, now.day);
      case "Quarterly":
        return DateTime(now.year, now.month - 3, now.day);
      case "Semi-Annual":
        return DateTime(now.year, now.month - 6, now.day);
      case "Annual":
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return now; // Default is "Daily", so return today's date
    }
  }

  // ✅ Generate Date Range for Selected Period
  List<String> _getDateRangeForPeriod(DateTime startDate, DateTime endDate) {
    List<String> dates = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      dates.add(DateFormat('yyyy-MM-dd').format(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return dates;
  }

  // ✅ Calculate Stress Distribution (Low, Moderate, High)
  void calculateStressDistribution(List<int> stressLevels) {
    if (stressLevels.isEmpty) return;

    int lowCount = stressLevels.where((s) => s <= 30).length;
    int moderateCount = stressLevels.where((s) => s > 30 && s <= 60).length;
    int highCount = stressLevels.where((s) => s > 60).length;
    int total = stressLevels.length;

    stressData.value = {
      "Low": (lowCount / total) * 100,
      "Moderate": (moderateCount / total) * 100,
      "High": (highCount / total) * 100,
    };

    print("📊 Updated Stress Data: $stressData");
  }

  // ✅ Calculate Average Stress Level
  void calculateAverageStress(List<int> stressLevels) {
    if (stressLevels.isEmpty) {
      averageStressLevel.value = 0;
      return;
    }

    double avg = stressLevels.reduce((a, b) => a + b) / stressLevels.length;
    averageStressLevel.value = avg;

    print("📊 Updated Average Stress Level: ${averageStressLevel.value}%");
  }
}
