import 'package:flutter/material.dart';

/// 📅 Calendar Day Widget with Heart Indicator
class CalendarDay extends StatelessWidget {
  final int day;
  final bool hasEntry;

  const CalendarDay({super.key, required this.day, required this.hasEntry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: hasEntry ? Colors.blue[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hasEntry ? Colors.blue : Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$day', style: TextStyle(fontWeight: FontWeight.bold, color: hasEntry ? Colors.blue : Colors.grey)),
          if (hasEntry) const Icon(Icons.favorite, color: Colors.red, size: 18),
        ],
      ),
    );
  }
}
