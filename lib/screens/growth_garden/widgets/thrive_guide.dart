import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';  // For fetching UID
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/thrive_guide_controller.dart';
import '../../../utils/constants/colors.dart';

class ThriveGuideScreen extends StatelessWidget {
  final ThriveGuideController controller = Get.put(ThriveGuideController());

  @override
  Widget build(BuildContext context) {
    final userUID = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get UID safely

    return Card(
      elevation: 5,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              child: const Text(
                'Thrive Guide',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Selected Plan (Reactive Data)
                    Obx(() => Text(
                      controller.selectedPlan.value,
                      style: GoogleFonts.archivo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )),

                    const SizedBox(height: 10),

                    // Plan Description (Reactive Data)
                    Obx(() => Text(
                      controller.planDescription.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    )),

                    const SizedBox(height: 10),

                    // Plan Activities (Reactive Data)
                    Obx(() => Column(
                      children: controller.planActivities
                          .map((activity) => Text(
                        activity,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ))
                          .toList(),
                    )),

                    const SizedBox(height: 15),

                    // Manage Plan Button
                    GestureDetector(
                      onTap: () => controller.showPlanSelectionDialog(context, userUID),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Manage Plan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
