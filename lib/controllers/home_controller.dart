import 'package:get/get.dart';

class HomeController extends GetxController {
  var shouldRefresh = false.obs; // ✅ Observable variable to trigger UI update

  void refreshHomeScreen() {
    shouldRefresh.value = !shouldRefresh.value; // ✅ Toggle value to force UI update
  }
}
