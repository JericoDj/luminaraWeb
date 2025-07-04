import 'package:flutter/material.dart';
import 'package:llps_mental_app/utils/constants/colors.dart';

class ConsultationToggle extends StatelessWidget {
  final String selectedType;
  final Function(String) onToggle;

  const ConsultationToggle({
    Key? key,
    required this.selectedType,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        children: [
          // Header Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: MyColors.color1,
            ),
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Service Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 0),

          // Toggle Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggleButton("Online"),
              _buildToggleButton("Face-to-Face"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String type) {
    final bool isSelected = selectedType == type;

    return Expanded(
      child: Column(
        children: [
          TextButton(
            onPressed: () => onToggle(type),
            child: Text(
              type,
              style: TextStyle(
                fontSize: isSelected ? 15 : 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? MyColors.color1: Colors.grey,

                decorationThickness: 2, // Thickness of underline
              ),
            ),
          ),

          // Animated Underline Below the Selected Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3, // Thickness of the underline
            width: isSelected ? 80 : 0, // Width of underline when selected
            decoration: BoxDecoration(
              color: isSelected ? MyColors.color1: Colors.transparent, // Green underline if selected
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
