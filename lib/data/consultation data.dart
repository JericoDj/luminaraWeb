import '../models/consultation_models.dart';

List<Consultation> getConsultationData(int index) {
  switch (index) {
    case 0: // Requests
      return [
        Consultation(
          serviceType: "Psychological Assessment",
          serviceId: "REQ-001",
          status: "Pending",
          bookedDate: "January 15, 2024",
          bookedTime: "01:30 PM",
          createdDate: "January 01, 2024",
          createdTime: "09:00 AM",
        ),
        Consultation(
          serviceType: "Consultation",
          serviceId: "REQ-002",
          status: "Pending",
          bookedDate: "January 16, 2024",
          bookedTime: "02:00 PM",
          createdDate: "January 02, 2024",
          createdTime: "10:30 AM",
        ),
      ];
    case 1: // Scheduled
      return [
        Consultation(
          serviceType: "Couple Therapy",
          serviceId: "SCH-003",
          status: "Scheduled",
          bookedDate: "January 21, 2024",
          bookedTime: "03:30 PM",
          createdDate: "January 10, 2024",
          createdTime: "11:45 AM",
        ),
      ];
    case 2: // Finished
      return [
        Consultation(
          serviceType: "Health Check-up",
          serviceId: "FIN-004",
          status: "Completed",
          bookedDate: "January 08, 2024",
          bookedTime: "10:00 AM",
          createdDate: "December 26, 2023",
          createdTime: "08:45 AM",
        ),
      ];
    default:
      return [];
  }
}
