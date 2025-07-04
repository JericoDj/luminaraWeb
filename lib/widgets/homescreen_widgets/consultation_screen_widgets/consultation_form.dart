import 'package:flutter/material.dart';
import 'package:llps_mental_app/utils/constants/colors.dart';
import 'package:llps_mental_app/widgets/homescreen_widgets/consultation_screen_widgets/specialist_selection.dart';
import 'consultation_toggle.dart';
import 'date_time_selection.dart';

class ConsultationForm extends StatelessWidget {
  final String selectedConsultationType;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? selectedService;
  final Function() onPickDate;
  final Function(TimeOfDay) onPickTime;
  final Function(String) onSelectService;
  final Function(String) onToggleType;

  const ConsultationForm({    Key? key,
    required this.selectedConsultationType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedService,
    required this.onPickDate,
    required this.onPickTime,
    required this.onSelectService,
    required this.onToggleType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Card(
            elevation: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: MyColors.color2.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                textAlign: TextAlign.center,
                "Book a session with a professional at your convenience. We're ready to assist you when needed.",
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFfcbc1d),
                Color(0xFFfd9c33),
                Color(0xFF59b34d),
                Color(0xFF359d4e),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ConsultationToggle(

                        selectedType: selectedConsultationType,
                        onToggle: onToggleType,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SpecialistSelection(
                    selectedService: selectedService,
                    onSelectService: onSelectService,
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Date Picker Button with Gradient Border
                      GestureDetector(
                        onTap: onPickDate,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: selectedDate == null
                                  ? [
                                Colors.black45,
                                Colors.black54
                              ] // Black gradient if no date is selected
                                  : [MyColors.color1, MyColors.color2],
                              // Custom gradient if date is selected
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(2),
                          // Creates the gradient border effect
                          child: Container(
                            height: 50,
                            width: 140,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                selectedDate != null
                                    ? "${selectedDate!.toLocal()
                                    .toString()
                                    .split(' ')[0]}"
                                    : "Select Date",
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? Colors.black87.withAlpha(
                                      180) // Faded text if not selected
                                      : MyColors.black,
                                  // Highlighted if selected
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      // Time Picker Button with Gradient Border
                      GestureDetector(
                        onTap: () => _showTimePicker(context),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: selectedTime == null
                                  ? [
                                Colors.black45,
                                Colors.black54
                              ] // Black gradient if no time is selected
                                  : [MyColors.color1, MyColors.color2],
                              // Custom gradient if time is selected
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(2),
                          // Creates the gradient border effect
                          child: Container(
                            height: 50,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                selectedTime != null
                                    ? selectedTime!.format(context)
                                    : "Select Time",
                                style: TextStyle(
                                  color: selectedTime == null
                                      ? Colors.black87.withAlpha(
                                      180) // Faded text if not selected
                                      : MyColors.black,
                                  // Highlighted if selected
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }


  void _showTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // Rounded top corners
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true, // **Allows full height usage**
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.6, // **Increase modal height (70% of screen)**
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Title
                Text(
                  "Select a Time Slot",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyColors.color1,
                  ),
                ),
                const SizedBox(height: 30), // **Increased spacing after title**
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // **2 Columns for Better Display**
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 3, // **Wider Buttons**
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final time = TimeOfDay(hour: 9 + index, minute: 0);
                      return GestureDetector(
                        onTap: () {
                          onPickTime(time);
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: MyColors.color2, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            time.format(context),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87, // **Text Color**
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // **More space before "Cancel" button**
                // Cancel Button (Moved Higher)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.redAccent, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent, // **Text Color**
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

}