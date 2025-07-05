import 'package:get/get.dart';
import 'user_progress_controller.dart'; // Import UserProgressController

class ProgressController extends GetxController {
  late final UserProgressController userProgressController;

  var achievements = "My".obs;
  var moodTrends = "😊".obs;
  var stressLevel = "Moderate".obs;

  @override
  void onInit() {
    super.onInit();

    // Ensure UserProgressController is initialized once
    if (!Get.isRegistered<UserProgressController>()) {
      userProgressController = Get.put(UserProgressController());
    } else {
      userProgressController = Get.find<UserProgressController>();
    }

    userProgressController.fetchUserCheckIns(); // Ensure check-in data is loaded
  }
}
