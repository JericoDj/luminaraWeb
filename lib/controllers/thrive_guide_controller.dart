import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/storage/user_storage.dart';
import '../../../utils/constants/colors.dart';

class ThriveGuideController extends GetxController {
  final UserStorage userStorage = UserStorage();

  var selectedPlan = 'No plan selected'.obs;
  var planDescription = 'Choose a plan to start your journey.'.obs;
  var planActivities = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedPlanDetails();
  }

  // ✅ Load saved plan details from storage
  void _loadSavedPlanDetails() async {
    final savedPlan = userStorage.getPlanDetails();
    if (savedPlan != null) {
      selectedPlan.value = savedPlan['title'];
      await _fetchPlanDetails(savedPlan['title']);
    }
  }

  // ✅ Fetch Description & Activities from `/plans`
  Future<void> _fetchPlanDetails(String planTitle) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('plans')
          .doc(planTitle)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        planDescription.value = data?['description'] ?? 'No description available.';
        planActivities.value = List<String>.from(data?['activities'] ?? []);
      } else {
        planDescription.value = 'Plan details not found.';
        planActivities.clear();
      }
    } catch (e) {
      planDescription.value = 'Error loading plan details.';
      planActivities.clear();
    }
  }

  // ✅ Plan Selection Dialog with UID Parameter
  void showPlanSelectionDialog(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(context),
              const SizedBox(height: 15),

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('plans').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No plans available.'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(data['title'] ?? 'No Title'),
                        subtitle: Text(data['description'] ?? 'No Description'),
                        onTap: () => _showConfirmationDialog(
                          context,
                          data['title'] ?? 'No Title',
                          data['description'] ?? '',
                          List<String>.from(data['activities'] ?? []),
                          _formatDuration(data['days'] ?? 0),
                          data['days'] ?? 0,
                          uid,
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 15),
              _buildDialogActionButton('Cancel', () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Confirmation Dialog with Snackbar
  void _showConfirmationDialog(
      BuildContext context,
      String title,
      String description,
      List<String> activities,
      String duration,
      int days,
      String uid
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Plan Selection'),
        content: Text('Are you sure you want to select the "$title" plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              try {
                selectedPlan.value = title;
                planDescription.value = '$description\nDuration: $duration';
                planActivities.value = activities;

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('plans')
                    .add({
                  'title': title,
                  'date_start': DateTime.now(),
                  'date_end': DateTime.now().add(Duration(days: days)),
                });

                userStorage.savePlanDetails({
                  'title': title,
                  'description': planDescription.value,
                  'activities': activities,
                });

                Get.snackbar(
                  'Success',
                  'The "$title" plan has been successfully selected!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to select plan. Please try again.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }

              Navigator.pop(context); // Close confirmation
              Navigator.pop(context); // Close selection dialog
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // ✅ Dialog Header
  Widget _buildDialogHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Select Wellness Plan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ✅ Duration Formatter
  String _formatDuration(int days) {
    if (days < 7) {
      return '$days Day${days > 1 ? 's' : ''}';
    } else if (days < 30) {
      return '${days ~/ 7} Week${days >= 14 ? 's' : ''}';
    } else {
      return '${days ~/ 30} Month${days >= 60 ? 's' : ''}';
    }
  }

  // ✅ Dialog Action Button
  Widget _buildDialogActionButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: MyColors.color1)),
    );
  }
}