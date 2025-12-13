import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LogNotificationController extends GetxController {
  final Box _box = Hive.box('notificationBox');
  
  // Observable list untuk UI
  var notifications = <Map<dynamic, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    // Ambil data dari Hive, balik urutan agar yang terbaru di atas
    final data = _box.values.toList().cast<Map<dynamic, dynamic>>();
    notifications.assignAll(data.reversed.toList());
  }

  Future<void> clearLogs() async {
    await _box.clear();
    notifications.clear();
    Get.snackbar("Info", "Riwayat notifikasi dihapus");
  }
}