import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../mindful_breathing_techniques/4-7-8_breathing.dart';
import '../mindful_breathing_techniques/alternate_nostril_breathing.dart';
import '../mindful_breathing_techniques/box_breathing.dart';

import '../quick_meditation_techniques/body_scan_meditation.dart';
import '../quick_meditation_techniques/breath_awareness.dart';
import '../quick_meditation_techniques/gratitude_meditation.dart';
import 'feature_cards.dart';
import 'insight_quest.dart';

class QuickWellnessTools extends StatelessWidget {
  const QuickWellnessTools({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FeatureCard(
              title: 'Mindful Breathing',
              icon: Icons.air,
              description: 'Guided breathing exercises to calm the mind.',
              onTap: () => _showBreathingDialog(context),
              width: MediaQuery.of(context).size.width < 510
                  ? MediaQuery.of(context).size.width / 2 - 20
                  : 500 / 2 - 20,
            ),
            const SizedBox(width: 15),
            FeatureCard(
              title: 'Quick Meditation',
              icon: Icons.self_improvement,
              description: 'A 5-minute mindfulness session.',
              onTap: () => _showMeditationDialog(context),
              width: MediaQuery.of(context).size.width < 510
                  ? MediaQuery.of(context).size.width / 2 - 20
                  : 500 / 2 - 20,
            ),
          ],
        ),
      ),
    );
  }

  // 🌬️ Pop-up for Breathing Techniques
  void _showBreathingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Choose a Breathing Exercise', style: TextStyle(fontSize: 16),),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogOption(context, 'Box Breathing (4-4-4-4)', 'Inhale, hold, exhale, hold for 4 seconds each.', () => _navigateToBreathingScreen(context, 'Box Breathing')),
              _dialogOption(context, '4-7-8 Breathing', 'Inhale for 4s, hold for 7s, exhale for 8s.', () => _navigateToBreathingScreen(context, '4-7-8 Breathing')),
              _dialogOption(context, 'Alternate Nostril Breathing', 'Breathe through alternate nostrils.', () => _navigateToBreathingScreen(context, 'Alternate Nostril Breathing')),
            ],
          ),
        );
      },
    );
  }

  // 🧘 Pop-up for Meditation Techniques
  void _showMeditationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Choose a Meditation', style: TextStyle(fontSize: 16),),
              IconButton(
                icon: const Icon(CupertinoIcons.xmark_circle),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogOption(context, 'Body Scan Meditation', 'Relax by focusing on different body parts.', () => _navigateToMeditationScreen(context, 'Body Scan Meditation')),
              _dialogOption(context, 'Gratitude Meditation', 'Focus on things you are grateful for.', () => _navigateToMeditationScreen(context, 'Gratitude Meditation')),
              _dialogOption(context, 'Breath Awareness Meditation', 'Focus on your natural breathing pattern.', () => _navigateToMeditationScreen(context, 'Breath Awareness Meditation')),
            ],
          ),
        );
      },
    );
  }

  // Helper function for dialog options
  Widget _dialogOption(BuildContext context, String title, String description, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: MyColors.color2.withOpacity(0.2),
        ),
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(description),
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
        ),
      ),
    );
  }


  // 🚀 Navigate to Breathing Screens
  void _navigateToBreathingScreen(BuildContext context, String breathingType) {
    Widget screen;
    switch (breathingType) {
      case 'Box Breathing':
        screen = const BoxBreathingScreen();
        break;
      case '4-7-8 Breathing':
        screen = const FourSevenEightBreathingScreen();
        break;
      case 'Alternate Nostril Breathing':
        screen = const AlternateNostrilBreathingScreen();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // 🚀 Navigate to Meditation Screens
  void _navigateToMeditationScreen(BuildContext context, String meditationType) {
    Widget screen;
    switch (meditationType) {
      case 'Body Scan Meditation':
        screen = const BodyScanMeditationScreen();
        break;
      case 'Gratitude Meditation':
        screen = const
        GratitudeMeditationScreen();
        break;
      case 'Breath Awareness Meditation':
        screen = const BreathAwarenessMeditationScreen();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
