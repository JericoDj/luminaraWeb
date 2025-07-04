import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../screens/homescreen/calling_customer_support_screen.dart';
import '../../utils/constants/colors.dart';

class CallCustomerSupportPopup extends StatefulWidget {
  @override
  _CallCustomerSupportPopupState createState() => _CallCustomerSupportPopupState();
}

class _CallCustomerSupportPopupState extends State<CallCustomerSupportPopup> {
  bool _agreeToPrivacy = false;
  double _dragPosition = 0.0;
  bool _dragReachedEnd = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = 280.0;
    double draggableSize = 50.0;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Call Customer Support"),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: MyColors.color2),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "To proceed with customer support, please agree to our data privacy policy.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: _agreeToPrivacy,
                activeColor: MyColors.color1,
                onChanged: (value) {
                  setState(() => _agreeToPrivacy = value!);
                },
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "I agree to the data privacy policy.",
                  style: TextStyle(
                    fontSize: 14,
                    color: MyColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                width: buttonWidth,
                height: 50,
                decoration: BoxDecoration(
                  color: _agreeToPrivacy ? MyColors.color2 : Colors.grey,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Slide to Proceed",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_agreeToPrivacy) {
                      setState(() {
                        _dragPosition += details.delta.dx;
                        if (_dragPosition < 0) {
                          _dragPosition = 0;
                          _dragReachedEnd = false;
                        } else if (_dragPosition > buttonWidth - draggableSize) {
                          _dragPosition = buttonWidth - draggableSize;
                          _dragReachedEnd = true;
                        } else {
                          _dragReachedEnd = false;
                        }
                      });
                    }
                  },
                  onHorizontalDragEnd: (_) {
                    if (_dragReachedEnd) {
                      Navigator.of(context).pop();
                      Get.to(() => CallingCustomerSupportScreen(
                        roomId: null,
                        isCaller: true,
                      ));
                    } else {
                      setState(() => _dragPosition = 0);
                    }
                  },
                  child: _buildDraggableIcon(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableIcon() {
    return Container(
      height: 50,
      width: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.arrow_forward, color: MyColors.color1),
    );
  }
}
