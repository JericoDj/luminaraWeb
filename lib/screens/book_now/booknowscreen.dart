import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../controllers/session_controller.dart';
import '../../utils/constants/colors.dart';
import '../../widgets/homescreen_widgets/call_customer_support_widget.dart';
import '../../widgets/homescreen_widgets/consultation_screen_widgets/bottom_buttons.dart';
import '../../widgets/homescreen_widgets/consultation_screen_widgets/consultation_form.dart';
import '../homescreen/booking_review_screen.dart';

class BookNowScreen extends StatefulWidget {
  const BookNowScreen({Key? key}) : super(key: key);

  @override
  State<BookNowScreen> createState() => _BookNowScreenState();
}

class _BookNowScreenState extends State<BookNowScreen> {
  String _selectedConsultationType = "Online"; // Default consultation type
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedService;

  // Access SessionController to get session data
  // late SessionController sessionController;

  @override
  void initState() {
    super.initState();
    // sessionController = Get.find<SessionController>(); // Initialize controller

    // Show welcome dialog when the screen loads
    Future.delayed(Duration.zero, () {
      _showWelcomeDialog();
    });
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Make dialog wrap content
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Safe Space",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyColors.color1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  "Connect with a mental health professional for support.",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),


                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                    decoration: BoxDecoration(
                      color: MyColors.color2, // Custom button color
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Okay",
                        style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickDate() {
    DateTime today = DateTime.now();
    DateTime firstSelectableDate = today.add(const Duration(days: 2));
    DateTime lastSelectableDate = firstSelectableDate.add(const Duration(days: 365));

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: MyColors.color2,
            hintColor: MyColors.color2,
            textTheme: const TextTheme(
              headlineMedium: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            colorScheme: ColorScheme.light(
              primary: MyColors.color2,
              onPrimary: Colors.white70,
              onSurface: MyColors.color1,
            ),
            dialogBackgroundColor: Colors.white,
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                const Text(
                  "Choose a Date",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CalendarDatePicker(
                  initialDate: firstSelectableDate,
                  firstDate: firstSelectableDate,
                  lastDate: lastSelectableDate,
                  onDateChanged: (DateTime newDate) {
                    Navigator.pop(context);
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Note: Choose your preferred date. Please note that the final schedule may be adjusted based on our professional’s availability.",
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 60),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }


  void _pickTime(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _bookSession() {
    if (_selectedDate != null && _selectedTime != null && _selectedService != null) {
      context.push(
        Uri(
          path: '/booking-review',
          queryParameters: {
            'consultationType': _selectedConsultationType,
            'selectedDate': DateFormat('EEE, MMM d').format(_selectedDate!),
            'selectedTime': _selectedTime!.format(context),
            'service': _selectedService!,
          },
        ).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFormComplete = _selectedDate != null && _selectedTime != null && _selectedService != null;

    return Scaffold(
      backgroundColor: Colors.white,


      body: Align(
        alignment: Alignment.topCenter,
        child: Container(

          width: MediaQuery.of(context).size.width * 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Consultation Form
                  ConsultationForm(
                    selectedConsultationType: _selectedConsultationType,
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                    selectedService: _selectedService,
                    onPickDate: _pickDate,
                    onPickTime: _pickTime,
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
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        child: BottomButtons(
          isFormComplete: isFormComplete,
          onBookSession: _bookSession,
          onCallSupport: () => showDialog(
            context: context,
            builder: (context) => CallCustomerSupportPopup(),
          ),
        ),
      ),
    );
  }
}
