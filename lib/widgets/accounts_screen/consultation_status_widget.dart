import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/consultation_controller.dart';
import '../../models/consultation_models.dart';
import '../../screens/account_screen/accounts_privacy/full_list_page.dart';
import '../../screens/account_screen/consultation_pages/consultation_detail.dart';
import 'package:llps_mental_app/utils/constants/colors.dart';

class ConsultationStatusWidget extends StatelessWidget {
  final ConsultationController consultationController = Get.put(ConsultationController());
  final RxString displayText = "Consultation Overview".obs;

  void navigateToDetailPage(BuildContext context, Consultation consultation) {
    showDetailDialog(
      context: context,
      serviceType: consultation.serviceType,
      serviceId: consultation.serviceId,
      status: consultation.status,
      bookedDate: consultation.bookedDate,
      bookedTime: consultation.bookedTime,
      createdDate: consultation.createdDate,
      meetingLink: consultation.meetingLink, // ✅ Now passing meeting link
      specialist: consultation.specialist, // ✅ Now passing specialist
    );
  }

  void updateDisplay(String status) {
    final count = consultationController.filteredConsultations.length;
    displayText.value = status == "requested"
        ? "Requests: You have $count pending requests."
        : status == "scheduled"
        ? "Scheduled: You have $count consultations scheduled."
        : "Finished: You have completed $count consultations.";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white30, Colors.white24],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 30,
              runSpacing: 10,
              children: [
                _buildStatusIcon(
                  icon: Icons.request_page,
                  label: "Requests",
                  onTap: () {
                    consultationController.filterConsultations("requested");
                    updateDisplay("requested");
                  },
                  count: consultationController.calculatePendingCount,
                ),
                _buildStatusIcon(
                  icon: Icons.schedule,
                  label: "Scheduled",
                  onTap: () {
                    consultationController.filterConsultations("scheduled");
                    updateDisplay("scheduled");
                  },
                  count: consultationController.calculateScheduledCount,
                ),
                _buildStatusIcon(
                  icon: Icons.check_circle,
                  label: "Finished",
                  onTap: () {
                    consultationController.filterConsultations("completed");
                    updateDisplay("completed");
                  },
                  count: consultationController.calculateFinishedCount,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildConsultationList(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: MyColors.color2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {
                    Get.to(() => FullListPage(
                      title: displayText.value.split(":")[0],
                      fullList: consultationController.consultations,
                    ));
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildConsultationList() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.black38,
      ),
      height: 350,
      width: double.infinity,
      child: Column(
        children: [
          Expanded(
            child: consultationController.filteredConsultations.isEmpty
                ? Center(
              child: Text(
                displayText.value.contains("Requests")
                    ? "No ongoing requests."
                    : displayText.value.contains("Scheduled")
                    ? "No scheduled consultations."
                    : "No finished consultations.",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: consultationController.filteredConsultations.length,
              itemBuilder: (context, index) {
                final item = consultationController.filteredConsultations[index];
                return GestureDetector(
                  onTap: () => navigateToDetailPage(context, item),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.serviceType,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(item.bookedDate),
                            const Spacer(),
                            Text(item.bookedTime),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}

Widget _buildStatusIcon({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  required int count,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 30, color: MyColors.color1),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        if (count > 0)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: MyColors.color2,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
