import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {

  final bool isFormComplete;
  final Function() onBookSession;
  final Function() onCallSupport;

  const BottomButtons({
    Key? key,

    required this.isFormComplete,
    required this.onBookSession,
    required this.onCallSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = isFormComplete;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10,),
          GestureDetector(
            onTap: onCallSupport,
            child: const Text(
              "Connect with customer support",
              style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: isButtonEnabled ? onBookSession : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isButtonEnabled ? Colors.white : Colors.black54,
                ),
                color: isButtonEnabled ? Colors.green : Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  if (isButtonEnabled) // Add shadow only when the button is enabled
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Center(
                child: Text(
                  "Book A Session",
                  style: TextStyle(
                    color: isButtonEnabled ? Colors.white : Colors.black54,  // Text color changes if greyed out
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 25),
        ],
      ),
    );
  }
}
