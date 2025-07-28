import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/consultation_controller.dart';
import '../../models/consultation_models.dart';
import '../../utils/constants/colors.dart';

class ConsultationStatusTabsWidget extends StatelessWidget {
  final ConsultationController controller = Get.put(ConsultationController());
  final RxString displayText = "Consultation Overview".obs;
  final RxString selectedStatus = "all".obs; // ✅ for active tab indicator

  ConsultationStatusTabsWidget({super.key});

  void _showConsultationDialog(BuildContext context, Consultation consultation) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          consultation.serviceType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Booked Date", consultation.bookedDate),
              _buildDetailRow("Booked Time", consultation.bookedTime),
              _buildDetailRow("Created Date", consultation.createdDate),
              _buildDetailRow("Created Time", consultation.createdTime),
              _buildDetailRow("Status", consultation.status.capitalizeFirst ?? "-"),
              if (consultation.meetingLink != null && consultation.meetingLink!.isNotEmpty)
                _buildDetailRow("Meeting Link", consultation.meetingLink!, isLink: true, context: context),
              if (consultation.resultLink != null && consultation.resultLink!.isNotEmpty)
                _buildDetailRow("Result Link", consultation.resultLink!, isLink: true, context: context),
              if (consultation.specialist != null && consultation.specialist!.isNotEmpty)
                _buildDetailRow("Specialist", consultation.specialist!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false, BuildContext? context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: isLink && context != null
                ? Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: MyColors.color1,
                      decoration: TextDecoration.underline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 20, color: MyColors.color1),
                  onPressed: () async {
                    final uri = Uri.parse(value);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open the link')),
                      );
                    }
                  },
                ),
              ],
            )
                : Text(value),
          ),
        ],
      ),
    );
  }

  void _updateStatus(String status) {
    selectedStatus.value = status;
    controller.filterConsultations(status);

    int count = controller.filteredConsultations.length;
    displayText.value = status == "requested"
        ? "Requests: You have $count pending requests."
        : status == "scheduled"
        ? "Scheduled: You have $count consultations scheduled."
        : status == "completed"
        ? "Finished: You have completed $count consultations."
        : "Consultation Overview";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white30, Colors.white24],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 30,
              children: [
                _buildStatusIcon(Icons.list, "All", "all", controller.consultations.length, () {
                  _updateStatus("all");
                }),
                _buildStatusIcon(Icons.request_page, "Requests", "requested", controller.calculatePendingCount, () {
                  _updateStatus("requested");
                }),
                _buildStatusIcon(Icons.schedule, "Scheduled", "scheduled", controller.calculateScheduledCount, () {
                  _updateStatus("scheduled");
                }),
                _buildStatusIcon(Icons.check_circle, "Completed", "finished", controller.calculateFinishedCount, () {
                  _updateStatus("finished");
                }),
              ],
            ),
            const SizedBox(height: 20),
            _buildConsultationList(context),
          ],
        ),
      ),
    ));
  }

  Widget _buildStatusIcon(IconData icon, String label, String statusKey, int count, VoidCallback onTap) {
    return Obx(() {
      final isSelected = selectedStatus.value == statusKey;
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
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: isSelected
                        ? Border.all(color: MyColors.color2, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: MyColors.color1, size: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildConsultationList(BuildContext context) {
    return Obx(() {
      final filtered = controller.filteredConsultations;
      return Container(
        height: 350,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: filtered.isEmpty
            ? const Center(
          child: Text(
            "No consultations.",
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            return GestureDetector(
              onTap: () => _showConsultationDialog(context, item),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.serviceType, style: const TextStyle(fontWeight: FontWeight.bold)),
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
      );
    });
  }
}
