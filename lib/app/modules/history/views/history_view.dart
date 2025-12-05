import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Untuk format tanggal (optional)
import '../controllers/history_controller.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pesanan")),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.orders.isEmpty) return const Center(child: Text("Belum ada pesanan"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            final isCOD = order['delivery_method'] == 'cod';
            final status = order['status'];
            final total = order['total_amount'];
            
            // Ambil nama lokasi jika COD
            final locationName = isCOD && order['meeting_points'] != null 
                ? order['meeting_points']['name'] 
                : 'Alamat Rumah';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: isDark ? const Color(0xFF2A2F36) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Order #${order['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCOD ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(isCOD ? "COD" : "Ekspedisi", 
                              style: TextStyle(color: isCOD ? Colors.blue : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text("Total: \$$total", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(isCOD ? "Titik Temu: $locationName" : "Tujuan: ${order['shipping_address']}", 
                        style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    
                    const SizedBox(height: 16),
                    
                    // --- TOMBOL LACAK (Hanya Muncul Jika COD) ---
                    if (isCOD) 
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => controller.resumeTracking(order),
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text("Buka Peta Tracking"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B9EE1),
                            foregroundColor: Colors.white
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}