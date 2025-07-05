import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/stress_controller.dart';
import '../../../../utils/constants/colors.dart';

class StressLevelSection extends StatelessWidget {
  StressLevelSection({
    Key? key,
    required List<GlobalKey<State<StatefulWidget>>> sectionKeys,
  }) : _sectionKeys = sectionKeys, super(key: key);

  final List<GlobalKey<State<StatefulWidget>>> _sectionKeys;
  final StressController stressController = Get.put(StressController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        key: _sectionKeys[3],
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
              // Title & Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Stress Level Management",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  DropdownButton<String>(
                    value: stressController.selectedPeriod.value,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    underline: Container(height: 1, color: Colors.black38),
                    items: ["Weekly", "Monthly", "Quarterly", "Semi-Annual", "Annual"].map((String period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (value) {
                      stressController.updatePeriod(value!);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Detailed Stress Level Section
              _buildDetailedStressLevel(),

              const SizedBox(height: 20),

              // Pie Chart
              _buildPieChart(),

              const SizedBox(height: 20),

              // Recommendations
              _buildRecommendations(),
            ],
          ),
        ),
      );
    });
  }

  // ✅ Detailed Stress Level Section (Good, Moderate, High, Critical)
  Widget _buildDetailedStressLevel() {
    double avgStress = stressController.averageStressLevel.value;
    String stressCategory = _getStressCategory(avgStress);
    Color stressColor = _getStressColor(stressCategory);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stressColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Your Average Stress Level: ${avgStress.toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "Category: $stressCategory",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: stressColor),
          ),
        ],
      ),
    );
  }

  // ✅ Pie Chart
  Widget _buildPieChart() {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: _buildPieChartSections(),
          centerSpaceRadius: 50,
          sectionsSpace: 4,
        ),
      ),
    );
  }

  // ✅ Pie Chart Data
  List<PieChartSectionData> _buildPieChartSections() {
    return stressController.stressData.entries.map((entry) {
      final isHighlighted = entry.value > 30;
      final color = _getSectionColor(entry.key);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.value.toInt()}%',
        radius: isHighlighted ? 65 : 50,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      );
    }).toList();
  }

  // ✅ Get Colors Based on Stress Level
  Color _getSectionColor(String level) {
    switch (level) {
      case "Low":
        return Colors.greenAccent;
      case "Moderate":
        return Colors.yellowAccent;
      case "High":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  // ✅ Recommendations Based on Stress Level
  Widget _buildRecommendations() {
    String recommendation = "You're doing great! Keep practicing mindfulness.";

    if (stressController.stressData["High"]! > 30) {
      recommendation = "High stress detected. Try deep breathing, meditation, or a short walk.";
    } else if (stressController.stressData["Moderate"]! > 40) {
      recommendation = "Moderate stress level. Incorporate breaks, sleep well, and stay hydrated.";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Get Stress Category Based on Average Stress Level
  String _getStressCategory(double avgStress) {
    if (avgStress <= 20) return "Good";
    if (avgStress <= 40) return "Moderate";
    if (avgStress <= 60) return "High";
    return "Critical";
  }

  // ✅ Get Stress Color Based on Category
  Color _getStressColor(String category) {
    switch (category) {
      case "Good":
        return Colors.green;
      case "Moderate":
        return Colors.yellow;
      case "High":
        return Colors.orange;
      case "Critical":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
