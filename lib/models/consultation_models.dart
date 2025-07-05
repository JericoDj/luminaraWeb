import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Consultation {
  final String serviceType;
  final String serviceId;
  final String status;
  final String bookedDate;
  final String bookedTime;
  final String createdDate;
  final String createdTime;
  final String? meetingLink; // ✅ Added optional field
  final String? specialist; // ✅ Added optional field

  Consultation({
    required this.serviceType,
    required this.serviceId,
    required this.status,
    required this.bookedDate,
    required this.bookedTime,
    required this.createdDate,
    required this.createdTime,
    this.meetingLink, // ✅ Optional
    this.specialist, // ✅ Optional
  });

  /// **🔥 Convert Firestore Document to `Consultation` Object**
  factory Consultation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // ✅ Extract created_at and format Date & Time properly
    String formattedDate = "N/A";
    String formattedTime = "Unknown Time";

    if (data['created_at'] != null) {
      DateTime createdAt = (data['created_at'] as Timestamp).toDate();
      formattedDate = DateFormat('yyyy-MM-dd').format(createdAt); // Extract Date
      formattedTime = DateFormat.jm().format(createdAt); // Extract Time in AM/PM format
    }

    return Consultation(
      serviceType: data['service'] ?? 'Unknown Service',
      serviceId: data['consultation_id'] ?? '',
      status: data['status'] ?? 'Unknown',
      bookedDate: data['date_requested'] ?? 'N/A',
      bookedTime: data['time'] ?? 'N/A',
      createdDate: formattedDate, // ✅ Properly formatted created date
      createdTime: formattedTime, // ✅ Properly formatted created time
      meetingLink: data.containsKey('meeting_link') ? data['meeting_link'] : null, // ✅ Check if exists
      specialist: data.containsKey('specialist') ? data['specialist'] : null, // ✅ Check if exists
    );
  }
}
