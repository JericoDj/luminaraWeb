import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/user_progress_controller.dart';
import '../../../../utils/constants/colors.dart';

class UserProgressSection extends StatelessWidget {
  UserProgressSection({
    Key? key,
    required List<GlobalKey<State<StatefulWidget>>> sectionKeys,
  })  : _sectionKeys = sectionKeys,
        super(key: key);

  final List<GlobalKey<State<StatefulWidget>>> _sectionKeys;
  final UserProgressController _progressController = Get.put(UserProgressController()); // Inject Controller

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Center( // Ensures entire section is centered
        child: Container(
          key: _sectionKeys[0],
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
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
                const Text(
                  "User Progress",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),

                // Centered Row with Check-ins and Streak
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle_outline,
                        value: _progressController.totalCheckIns.value.toString(),
                        label: "Monthly Check-ins",
                      ),
                    ),
                    const SizedBox(width: 20), // Space between cards
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        value: _progressController.streak.value.toString(),
                        label: "Streak",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Helper Method to Build Centered Stat Cards
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.color2, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Ensures vertical centering
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: MyColors.color1, size: 36),

            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18 ,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
