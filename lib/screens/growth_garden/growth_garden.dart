import 'package:flutter/material.dart';
import 'package:luminarawebsite/screens/growth_garden/widgets/gratitude_journaling_widget/gratitude_journaling_widget.dart';
import 'package:luminarawebsite/screens/growth_garden/widgets/insight_quest.dart';
import 'package:luminarawebsite/screens/growth_garden/widgets/mindhub.dart';
import 'package:luminarawebsite/screens/growth_garden/widgets/quick_wellness_tools.dart';
import 'package:luminarawebsite/screens/growth_garden/widgets/thrive_guide.dart';

class GrowthGardenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 1000;
          final isMediumScreen = constraints.maxWidth > 600;
      
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                // Hero Section
                Container(
                  width: isLargeScreen ? MediaQuery.of(context).size.width *0.40 : MediaQuery.of(context).size.width  * .9,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade100, Colors.lightGreen.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome to Your Growth Garden",
                        style: TextStyle(
                          fontSize: isLargeScreen ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        textAlign: TextAlign.center,
                        "Nurture your mental wellness with small daily actions.",
                        style: TextStyle(

                          fontSize: isLargeScreen ? 18 : 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
      
                // Thrive Guide
                // ThriveGuideScreen(),

      
                // Wellness Tools Grid
                Text(
                  "Quick Wellness Tools",
                  style: TextStyle(
                    fontSize: isLargeScreen ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height:30),
                if (isLargeScreen) ...[
                  // ➤ 3 cards in a row (large screen)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      QuickWellnessTools(),
                      const SizedBox(width: 15),
                      MindHubButton(),
                      const SizedBox(width: 15),
                       InsightQuestButton(),
                    ],
                  )
                ] else ...[
                  // ➤ Column layout (small to medium screen)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: QuickWellnessTools(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 25,
                            child: MindHubButton(),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 25,
                            child: InsightQuestButton(),
                          ),
                        ],
                      ),
                    ],
                  )
                ],


                const SizedBox(height: 30),
      
                // Gratitude Journal

                // GratitudeJournalWidget(),
                const SizedBox(height: 30),
      
                // Tools Row


                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}