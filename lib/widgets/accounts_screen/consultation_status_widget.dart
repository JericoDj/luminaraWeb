import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Consultation {
  final String serviceType;
  final String bookedDate;
  final String bookedTime;
  final String status;

  Consultation({
    required this.serviceType,
    required this.bookedDate,
    required this.bookedTime,
    required this.status,
  });
}

class ConsultationStatusTabsWidget extends StatefulWidget {
  const ConsultationStatusTabsWidget({super.key});

  @override
  State<ConsultationStatusTabsWidget> createState() => _ConsultationStatusTabsWidgetState();
}

class _ConsultationStatusTabsWidgetState extends State<ConsultationStatusTabsWidget> {
  final RxString selectedStatus = 'all'.obs;

  // Mock data
  final RxList<Consultation> consultations = <Consultation>[
    Consultation(serviceType: "Therapy", bookedDate: "2025-07-01", bookedTime: "10:00 AM", status: "requested"),
    Consultation(serviceType: "Counseling", bookedDate: "2025-07-03", bookedTime: "3:00 PM", status: "scheduled"),
    Consultation(serviceType: "Assessment", bookedDate: "2025-06-30", bookedTime: "1:00 PM", status: "completed"),
  ].obs;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusButtons(),
            const SizedBox(height: 16),
            _buildConsultationList(),
          ],
        )),
      ),
    );
  }

  Widget _buildStatusButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildTabButton("All", "all", Icons.list),
        _buildTabButton("Requests", "requested", Icons.request_page),
        _buildTabButton("Scheduled", "scheduled", Icons.schedule),
        _buildTabButton("Finished", "completed", Icons.check_circle),
      ],
    );
  }

  Widget _buildTabButton(String label, String value, IconData icon) {
    final isSelected = selectedStatus.value == value;
    return GestureDetector(
      onTap: () => selectedStatus.value = value,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 10)]
                  : [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Icon(icon, color: isSelected ? Colors.green : Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(

            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green : Colors.black,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 40,
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildConsultationList() {
    final filtered = selectedStatus.value == "all"
        ? consultations
        : consultations.where((c) => c.status == selectedStatus.value).toList();

    if (filtered.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "No ${selectedStatus.value} consultations.",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Wrap handles scroll
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.serviceType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        );
      },
    );
  }
}
