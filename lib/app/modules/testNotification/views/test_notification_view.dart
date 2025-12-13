import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/test_notification_controller.dart';

class TestNotificationView extends GetView<TestNotificationController> {
  const TestNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notification')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Eksplorasi Notifikasi Lokal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Tombol 1: Simple
            _buildButton(
              icon: Icons.notifications_none,
              title: "Simple Notification",
              subtitle: "Default System Sound",
              color: Colors.blue,
              onTap: () => controller.triggerSimple(),
            ),
            const SizedBox(height: 15),

            // Tombol 2: Custom Sound
            _buildButton(
              icon: Icons.music_note,
              title: "Custom Sound (Ringtone)",
              subtitle: "Suara: notif_sound.mp3",
              color: Colors.orange,
              onTap: () => controller.triggerCustomSound(),
            ),
            const SizedBox(height: 15),

            // Tombol 3: Progress
            _buildButton(
              icon: Icons.downloading,
              title: "Progress Notification",
              subtitle: "Simulasi Download 10 detik",
              color: Colors.green,
              onTap: () => controller.triggerProgress(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}