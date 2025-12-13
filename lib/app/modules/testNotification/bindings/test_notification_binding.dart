import 'package:get/get.dart';
import '../controllers/test_notification_controller.dart';

class TestNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestNotificationController>(() => TestNotificationController());
  }
}
