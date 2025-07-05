import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/homescreen_widgets/consultation_screen_widgets/consultation_form.dart';
import '../../../widgets/homescreen_widgets/consultation_screen_widgets/bottom_buttons.dart';
import '../../../widgets/homescreen_widgets/call_customer_support_widget.dart';
import '../booking_review_screen.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({Key? key}) : super(key: key);

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  String _selectedConsultationType = "Online";  // Default to Online
  DateTime? _selectedDateTime;
  String? _selectedService;
  int availableCredits = 5;

  // Pick Date and Time Together
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Customer Support Popup
  void _showCustomerSupportPopup() {
    showDialog(
      context: context,
      builder: (context) => CallCustomerSupportPopup(),
    );
  }

  // Book Session
  void _bookSession() {
    if (_selectedDateTime != null && _selectedService != null) {
      Get.to(() => BookingReviewScreen(
        consultationType: _selectedConsultationType,
        selectedDate: DateFormat('EEE., MMM. d').format(_selectedDateTime!),
        selectedTime: DateFormat('h:mm a').format(_selectedDateTime!),
        service: _selectedService!,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFormComplete = _selectedDateTime != null && _selectedService != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Safe Space"),
        backgroundColor: Colors.greenAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ConsultationForm(
              selectedConsultationType: _selectedConsultationType,
              selectedDate: _selectedDateTime,
              selectedTime: null,
              selectedService: _selectedService,
              onPickDate: _pickDateTime, // Now picks date & time together
              onPickTime: (time) {},
              onSelectService: (String service) {
                setState(() {
                  _selectedService = service;
                });
              },
              onToggleType: (type) {
                setState(() {
                  _selectedConsultationType = type;
                });
              },
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "Available Credits: $availableCredits",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomButtons(
        isFormComplete: isFormComplete,
        onBookSession: _bookSession,
        onCallSupport: _showCustomerSupportPopup,
      ),
    );
  }
}