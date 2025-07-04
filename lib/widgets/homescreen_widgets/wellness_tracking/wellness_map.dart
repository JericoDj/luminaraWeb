import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/achievements_popup.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/daily_mood_popup.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/mood_trends_popup.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/progress_popup.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/pop_ups/stress_level_popup.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/wellness_tracking/progress_buttons.dart';

import '../../../../utils/constants/colors.dart';
import '../../../controllers/moodTrackingController.dart';
import '../../../controllers/progress_controller.dart';
import '../../../screens/homescreen/wellness_tracking/progress_map_screen.dart';
import 'moods_section.dart';

class ProgressDashboardCard extends StatelessWidget {
  ProgressDashboardCard({Key? key}) : super(key: key);

  final ProgressController progressController = Get.put(ProgressController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                buildMoodSection(context),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        ProgressButtons(context), // Now controlled by GetX
      ],
    );
  }
}


  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [

            Color(0xFF59b34d),
            Color(0xFF359d4e),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(8),
        ),
      ),
      child: Text(
        "Wellness Map",
        textAlign: TextAlign.center,
        style: GoogleFonts.archivo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }


