import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/achievements_controller.dart';
import '../../../../utils/constants/colors.dart';

class AchievementsSection extends StatelessWidget {
  AchievementsSection({
    Key? key,
    required List<GlobalKey<State<StatefulWidget>>> sectionKeys,
  }) : _sectionKeys = sectionKeys, super(key: key);

  final List<GlobalKey<State<StatefulWidget>>> _sectionKeys;
  final AchievementsController _achievementsController = Get.put(AchievementsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<Map<String, dynamic>> achievements = _achievementsController.achievements;

      List<Map<String, dynamic>> unlockedAchievements = achievements.where((ach) => ach['unlocked']).toList();
      List<Map<String, dynamic>> lockedAchievements = achievements.where((ach) => !ach['unlocked']).toList();

      return Container(
        key: _sectionKeys[1],
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Achievements",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              if (unlockedAchievements.isNotEmpty) _buildUnlockedBadges(unlockedAchievements, context),

              const SizedBox(height: 20),

              _buildProgressSection(lockedAchievements, context),
            ],
          ),
        ),
      );
    });
  }
// ✅ Unlocked Achievements as Badges (Scrollable)
  Widget _buildUnlockedBadges(List<Map<String, dynamic>> achievements, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      height: 120, // 🔹 Fixed height to prevent layout breaking
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 🔹 Enable horizontal scrolling
        child: Row(
          children: achievements.map((achievement) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8), // 🔹 Space between items
              child: GestureDetector(
                onTap: () => _showAchievementDetails(context, achievement),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFfcbc1d),
                            Color(0xFFfd9c33),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.emoji_events, color: MyColors.color1, size: 32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10), // 🔹 Ensure space for full text
                      child: Text(
                        achievement["title"],
                        textAlign: TextAlign.center,
                        softWrap: true, // 🔹 Allow text wrapping
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }


  // ✅ Locked Achievements with Progress Bars (Clickable)
  Widget _buildProgressSection(List<Map<String, dynamic>> achievements, BuildContext context) {
    return Column(
      children: achievements.map((achievement) {
        return GestureDetector(
          onTap: () => _showAchievementDetails(context, achievement),
          child: _buildAchievementRow(
            icon: Icons.star,
            title: achievement["title"],
            progress: achievement["progress"],
            goal: achievement["goal"],
          ),
        );
      }).toList(),
    );
  }

  // ✅ Achievement Progress Bar Row
  Widget _buildAchievementRow({
    required IconData icon,
    required String title,
    required int progress,
    required int goal,
  }) {
    double progressPercentage = (progress / goal).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFfcbc1d),
                  Color(0xFFfd9c33),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: MyColors.color1, size: 28),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.black87.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: 10,
                          width: constraints.maxWidth * progressPercentage,
                          decoration: BoxDecoration(
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text("$progress / $goal"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Show Achievement Details Modal
  void _showAchievementDetails(BuildContext context, Map<String, dynamic> achievement) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement["title"],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Progress: ${achievement["progress"]} / ${achievement["goal"]}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                achievement["unlocked"]
                    ? "✅ This achievement is unlocked!"
                    : "🔒 Keep going to unlock this achievement.",
                style: TextStyle(
                  fontSize: 16,
                  color: achievement["unlocked"] ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
