import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectedDayDetails extends StatelessWidget {
  final String selectedDay;
  final String mood;

  const SelectedDayDetails({
    Key? key,
    required this.selectedDay,
    required this.mood,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "Selected Day: $selectedDay",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Mood: $mood",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}