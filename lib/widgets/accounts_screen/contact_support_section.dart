import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:llps_mental_app/utils/constants/colors.dart';

import 'TIcket_Popup_widget.dart';

class ContactSupportSection extends StatelessWidget {
  const ContactSupportSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFfcbc1d),
              Color(0xFFfd9c33),
              Color(0xFF59b34d),
              Color(0xFF359d4e),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: MyColors.color1,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),  // Top-left corner radius
                    topRight: Radius.circular(8), // Top-right corner radius
                  ),

                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Text(
                      'Need Help?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: Text(
                    'Contact our support team for assistance.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              /*const SizedBox(height: 20),

              // Phone Number Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Opacity(

                        opacity: 0.7,
                        child: Icon(Icons.phone, color: MyColors.color1,size: 24,)),
                    const SizedBox(width: 10),
                    Text(
                      '+63 917 854 2236',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Email Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal:  20.0),
                child: Row(
                  children: [
                    Opacity(

                        opacity: 0.7,
                        child:  Icon(Icons.email, color: MyColors.color1,size: 24,)),
                    const SizedBox(width: 20),
                    Text(
                      'support@llps.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
*/

              // Submit Ticket Button
              Padding(
                padding: EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    // Handle ticket submission
                    Get.to(() => SupportTicketsPage());
                  },
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: MyColors.color2, // Background color
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Submit a Ticket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ],
          ),
        ),
      ),
    );
  }
}
