import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';
import '../../utils/storage/user_storage.dart';
import '../../widgets/homescreen_widgets/eSignPopup.dart';
import '../../utils/constants/colors.dart';
import '../../widgets/navigation_bar.dart';

class BookingReviewScreen extends StatefulWidget {
  final String consultationType;
  final String selectedDate;
  final String selectedTime;
  final String service;

  const BookingReviewScreen({
    Key? key,
    required this.consultationType,
    required this.selectedDate,
    required this.selectedTime,
    required this.service,
  }) : super(key: key);

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  bool _isSubmitting = false; // ✅ Declare this variable

  bool _isContractChecked = false;
  bool _hasViewedContract =
      false; // Ensures users view contract before agreeing
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  Uint8List? _signatureImage;

  void _openESignPopup() async {
    await showDialog(
      context: context,
      builder: (context) =>
          ESignPopup(signatureController: _signatureController),
    );

    if (_signatureController.isNotEmpty) {
      final signature = await _signatureController.toPngBytes();
      setState(() {
        _signatureImage = signature;
      });
    }
  }

  void _openContractPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Informed Consent",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasViewedContract = true; // Mark contract as viewed
                  });
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.close, color: Colors.redAccent),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black), // Default style
                  children: [
                    TextSpan(
                      text: "I. Confidentiality\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "We are committed to keeping everything you share private and secure. However, there are situations where we may need to break confidentiality:\n"
                          "- If there is a risk of harm to yourself or others (e.g., suicidal or homicidal thoughts).\n"
                          "- If there is a legal requirement, such as a court order.\n"
                          "- If there is suspicion of child abuse, elder abuse, or abuse of a vulnerable individual.\n"
                          "- If you give written consent to share information with a third party (e.g., another healthcare provider or family member).\n\n",
                    ),

                    TextSpan(
                      text: "II. Voluntary Attendance\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "Your participation in sessions is voluntary, and you may discontinue at any time. However, we encourage you to discuss this with your mental health professional to ensure the best transition plan for your care.\n\n",
                    ),

                    TextSpan(
                      text: "III. Risks and Benefits\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "Therapy may bring up difficult emotions as we explore challenging topics. Progress takes time, and outcomes may vary. Your mental health professional will guide and support you throughout the process.\n\n",
                    ),

                    TextSpan(
                      text: "IV. Technology (for Online Sessions)\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "- We use Google Meet for online sessions.\n"
                          "- You are responsible for ensuring your device, internet connection, and passwords are secure.\n"
                          "- Your mental health professional is not responsible for breaches in confidentiality caused by client-side issues.\n\n",
                    ),

                    TextSpan(
                      text: "V. Disconnection Issues (for Online Sessions)\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "- If a technical issue interrupts the session, we will continue via phone.\n\n",
                    ),

                    TextSpan(
                      text: "VI. No Recording Policy\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "- To maintain session integrity, recording (audio/video) by either the client or the professional is strictly prohibited.\n\n",
                    ),

                    TextSpan(
                      text: "VII. Risk of Harm\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "- If you ever feel at risk of harming yourself or others, please inform your mental health professional immediately so that we can ensure your safety.\n\n",
                    ),

                    TextSpan(
                      text: "VIII. Records and Documentation\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "- Your mental health professional will maintain session notes to track progress. These records are kept confidential and secure.\n\n",
                    ),

                    TextSpan(
                      text: "IX. Cancellations & Rescheduling\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "- Please inform us **at least 48 hours in advance** if you need to cancel or reschedule a session.\n"
                          "- Failure to notify us in advance will result in a **paid session**.\n\n",
                    ),

                    TextSpan(
                      text: "X. No-Show and Late Attendance Policy\n",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: "- If you are not present within **30 minutes** of the scheduled session, it will be considered a **no-show**.\n"
                          "- If you expect to be late, please inform us. The session will continue for the remaining scheduled time.\n\n",
                    ),

                    TextSpan(
                      text: "Thank you for taking the time to read and understand this agreement. We are here to support you every step of the way!",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          actions: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _hasViewedContract = true; // Mark contract as viewed
                });
                Navigator.of(context).pop();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MyColors.white),
                    color: MyColors.color1),
                child: Text(
                  "I've Read",
                  style: TextStyle(
                      color: MyColors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleAgreement(bool? value) {
    if (!_hasViewedContract) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please view the Informed Consent before agreeing."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      setState(() {
        _isContractChecked = value!;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalPadding = constraints.maxWidth > 800 ? 400 : 16;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Review Your Booking Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFfcbc1d),
                          Color(0xFFfd9c33),
                          Color(0xFF59b34d),
                          Color(0xFF359d4e)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Consultation Type: ${widget.consultationType}",
                              style: TextStyle(
                                  color: MyColors.black,
                                  fontWeight: FontWeight.w600)),
                          Text("Date: ${widget.selectedDate}",
                              style: TextStyle(
                                  color: MyColors.black,
                                  fontWeight: FontWeight.w600)),
                          Text("Time: ${widget.selectedTime}",
                              style: TextStyle(
                                  color: MyColors.black,
                                  fontWeight: FontWeight.w600)),
                          Text("Service: ${widget.service}",
                              style: TextStyle(
                                  color: MyColors.black,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Informed Consent",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _openContractPopup,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFfcbc1d),
                            Color(0xFFfd9c33),
                            Color(0xFF59b34d),
                            Color(0xFF359d4e)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text("Tap to view the full Informed Consent.",
                            style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: MyColors.color2,
                        value: _isContractChecked,
                        onChanged: _toggleAgreement,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _toggleAgreement(!_isContractChecked);
                          },
                          child: const Text(
                            "I agree to the Informed Consent.",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _openESignPopup,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFfcbc1d),
                            Color(0xFFfd9c33),
                            Color(0xFF59b34d),
                            Color(0xFF359d4e)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8)),
                        child: _signatureImage != null
                            ? Image.memory(_signatureImage!,
                            width: 200, height: 100, fit: BoxFit.contain)
                            : const SizedBox(
                          width: 200,
                          height: 100,
                          child: Center(
                              child: Text("Tap to Sign",
                                  style: TextStyle(color: Colors.grey))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isSubmitting ? null : _showConfirmationDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _isSubmitting ? Colors.grey : MyColors.color2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Submit Request",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showConfirmationDialog() async {
    if (!_hasViewedContract || !_isContractChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "You must read and agree to the contract before submitting."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_signatureImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide an e-signature before submitting."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Disable submit button to prevent multiple submissions
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _saveBookingToFirebase(); // Call function to save booking
      _showSuccessDialog(); // Show confirmation after successful submission
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting request: $error"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Appointment Submitted",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Your request has been submitted. A representative will contact you within 24 hours to finalize your booking through your registered mobile number.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16),
              Text(
                "Make sure that your contact number is active. Please note that the final schedule may be adjusted based on our professional’s availability.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                   context.pushReplacement("/account");
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: MyColors.color2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }



  Future<void> _saveBookingToFirebase() async {
    String? userId = UserStorage().getUid();
    String? username = UserStorage().getUsername();
    String? companyId = UserStorage().getCompanyId();
    String? fullName = await UserStorage().getFullName(); // ✅ Use async version
    String? phone = await UserStorage().getPhoneNumber(); // ✅ Also async

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not found. Please log in again."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String consultationId =
        FirebaseFirestore.instance.collection('bookings').doc().id;

    try {
      // ✅ Upload signature to Firebase Storage
      String filePath = "consultations/$consultationId/sign.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = storageRef.putData(_signatureImage!);
      TaskSnapshot storageSnapshot = await uploadTask;
      String signatureUrl = await storageSnapshot.ref.getDownloadURL();

      // ✅ Save booking details to Firestore
      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(consultationId)
          .set({
        "consultation_id": consultationId,
        "user_id": userId,
        "username": username ?? "",
        "full_name": fullName ?? "",
        "phone": phone ?? "", // ✅ Save phone number
        "company_id": companyId ?? "",
        "consultation_type": widget.consultationType,
        "date_requested": widget.selectedDate,
        "time": widget.selectedTime,
        "service": widget.service,
        "status": "Requested",
        "signature_url": signatureUrl,
        "created_at": FieldValue.serverTimestamp(),
      });

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving booking: $error"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }



}
