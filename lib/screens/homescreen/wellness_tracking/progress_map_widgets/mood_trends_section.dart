import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/MoodController.dart';
import '../../../../utils/constants/colors.dart';

class MoodSection extends StatelessWidget {
  MoodSection({
    Key? key,
    required List<GlobalKey<State<StatefulWidget>>> sectionKeys,
    this.selectedDay,
  }) : _sectionKeys = sectionKeys, super(key: key);

  final List<GlobalKey<State<StatefulWidget>>> _sectionKeys;
  final MoodController _moodController = Get.put(MoodController());

  final String? selectedDay;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        key: _sectionKeys[2],
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              Color(0xFFfcbc1d),
              Color(0xFFfd9c33),
              Color(0xFF59b34d),
              Color(0xFF359d4e),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Dropdown for Period Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Mood Trends",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  DropdownButton<String>(
                    value: _moodController.selectedPeriod.value,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    underline: Container(height: 1, color: Colors.black87),
                    items: ["Weekly", "Monthly", "Quarterly", "Semi-Annual", "Annual"].map((String period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _moodController.updatePeriod(value!);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildDailyMoodRow(),
              const SizedBox(height: 24),

              _buildMoodBarChart(),
            ],
          ),
        ),
      );
    });
  }




  /// ✅ **Mood History (Latest 7 Days)**
  Widget _buildDailyMoodRow() {
    List<Map<String, String>> days = _moodController.getLatestMoods(_moodController.getDaysFromPeriod(_moodController.selectedPeriod.value));

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final moodEntry = days[index];
          String moodEmoji = _getMoodEmoji(moodEntry["mood"]!);

          return GestureDetector(
            onTap: () => _showMoodDetails(moodEntry["date"]!, moodEntry["mood"]!),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(moodEntry["day"]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(moodEmoji, style: const TextStyle(fontSize: 30)), // ✅ Show emoji
                  const SizedBox(height: 5),
                  Text(DateFormat('MMM d').format(DateTime.parse(moodEntry["date"]!)), style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }




  /// ✅ **Show Mood Details in a Snackbar**
  void _showMoodDetails(String date, String mood) {
    Get.snackbar(
      "Mood Details",
      "Mood on $date: $mood",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      duration: Duration(seconds: 2),
    );
  }

  /// ✅ **Mood Mapping Function (Text → Emoji)**
  String _getMoodEmoji(String mood) {
    const moodEmojis = {
      "Happy": "😊",
      "Neutral": "😐",
      "Sad": "😢",
      "Angry": "😠",
      "Anxious": "😰",
    };
    return moodEmojis[mood] ?? "⬜";
  }

  /// ✅ **Mood Frequency Chart (Now Uses Only Latest 7 Days)**
  Widget _buildMoodBarChart() {
    final moodData = _moodController.getMoodCounts(); // ✅ Fetch moods dynamically

    int maxMoodCount = moodData.isNotEmpty ? moodData.values.reduce((a, b) => a > b ? a : b) : 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moodData.entries.map((entry) {
        double heightFactor = maxMoodCount > 0 ? entry.value / maxMoodCount : 0;

        return Column(
          children: [
            Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 100,
              width: 30,
              decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getBarColor(entry.key),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text("${entry.value}", style: const TextStyle(fontSize: 14)),
          ],
        );
      }).toList(),
    );
  }

  /// ✅ **Mood Colors for Chart**
  Color _getBarColor(String mood) {
    return {"Happy": Colors.greenAccent, "Neutral": Colors.yellow, "Sad": Colors.red, "Angry": Colors.orange, "Anxious": Colors.blue}[mood] ?? Colors.grey;
  }
}
