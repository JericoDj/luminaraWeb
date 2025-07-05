import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/consultation_models.dart';

class ConsultationController extends GetxController {
  RxList<Consultation> consultations = <Consultation>[].obs;
  RxList<Consultation> filteredConsultations = <Consultation>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchConsultations();
  }

  /// **🔥 Fetch Real-Time Consultations from Firestore**
  void fetchConsultations() {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _firestore
        .collection("bookings")
        .where("user_id", isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      final List<Consultation> fetchedConsultations = snapshot.docs
          .map((doc) => Consultation.fromFirestore(doc))
          .toList();

      consultations.assignAll(fetchedConsultations); // ✅ Update list
      filterConsultations("all"); // ✅ Default: Show all consultations
      update();
    });
  }

  /// **🔥 Filter Consultations by Status**
  void filterConsultations(String status) {
    if (status.toLowerCase() == "all") {
      filteredConsultations.assignAll(consultations);
    } else {
      filteredConsultations.assignAll(
        consultations.where((c) => (c.status ?? "").toLowerCase() == status.toLowerCase()).toList(),
      );
    }
    update();
  }

  /// **🔥 Get Consultation Details by ID**
  Future<Consultation?> getConsultationDetails(String consultationId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("bookings").doc(consultationId).get();
      if (doc.exists) {
        return Consultation.fromFirestore(doc);
      }
    } catch (e) {
      print("❌ Error fetching consultation details: $e");
    }
    return null;
  }

  /// **🔥 Get Pending Consultations Count**
  int get calculatePendingCount => consultations
      .where((c) => (c.status ?? "").toLowerCase() == "requested")
      .length;

  /// **🔥 Get Scheduled Consultations Count**
  int get calculateScheduledCount => consultations
      .where((c) => (c.status ?? "").toLowerCase() == "scheduled")
      .length;

  /// **🔥 Get Completed Consultations Count**
  int get calculateFinishedCount => consultations
      .where((c) => (c.status ?? "").toLowerCase() == "completed")
      .length;
}
