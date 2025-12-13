import 'package:get/get.dart';
import 'package:demo_modul5/app/data/services/notification_handler.dart';

class TestNotificationController extends GetxController {
  // Panggil handler
  final NotificationHandler _handler = NotificationHandler();

  @override
  void onInit() {
    super.onInit();
    _handler.initLocalNotification(); // Pastikan terinisialisasi
  }

  void triggerSimple() {
    _handler.showSimpleNotification();
    Get.snackbar("Success", "Notifikasi biasa dikirim!");
  }

  void triggerCustomSound() {
    _handler.showCustomSoundNotification();
    Get.snackbar("Success", "Notifikasi custom sound dikirim!");
  }

  void triggerProgress() {
    _handler.showProgressNotification();
    Get.snackbar("Downloading", "Cek panel notifikasi Anda...");
  }
}