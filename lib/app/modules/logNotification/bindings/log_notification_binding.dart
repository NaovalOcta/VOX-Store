import 'package:get/get.dart';
import '../controllers/log_notification_controller.dart';

class LogNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LogNotificationController>(() => LogNotificationController());
  }
}
