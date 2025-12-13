import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/log_notification_controller.dart';

class LogNotificationView extends GetView<LogNotificationController> {
  const LogNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => controller.clearLogs(),
            tooltip: "Hapus Semua",
          )
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text("Belum ada notifikasi", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            final date = DateTime.parse(notif['date']);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications, color: Colors.blue),
                ),
                title: Text(
                  notif['title'] ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(notif['body'] ?? ''),
                    const SizedBox(height: 6),
                    Text(
                      "${date.day}/${date.month} ${date.hour}:${date.minute}",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      }),
    );
  }
}