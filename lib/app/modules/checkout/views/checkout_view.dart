import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2F36) : Colors.white;
    const primaryBlue = Color(0xFF5B9EE1);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item List Ringkas
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.cartC.cartItems.length,
              itemBuilder: (context, index) {
                final item = controller.cartC.cartItems[index];
                return Card(
                  color: cardColor,
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text("${item.quantity} x ${item.price}"),
                    trailing: Text(item.size),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Metode Pengiriman
            const Text("Metode Pengiriman", style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => Column(
              children: [
                RadioListTile(
                  title: const Text("COD (Cash On Delivery)"),
                  value: 'cod',
                  groupValue: controller.selectedDeliveryMethod.value,
                  onChanged: (val) => controller.selectedDeliveryMethod.value = val.toString(),
                ),
                RadioListTile(
                  title: const Text("Ekspedisi"),
                  value: 'expedition',
                  groupValue: controller.selectedDeliveryMethod.value,
                  onChanged: (val) => controller.selectedDeliveryMethod.value = val.toString(),
                ),
              ],
            )),

            // Form Alamat / Peta
            Obx(() {
              if (controller.selectedDeliveryMethod.value == 'cod') {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text(controller.selectedMeetingPoint.value?.name ?? "Belum pilih lokasi"),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: controller.pickLocation,
                        icon: const Icon(Icons.map),
                        label: const Text("Pilih Lokasi di Peta"),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
                      )
                    ],
                  ),
                );
              } else {
                return TextField(
                  controller: controller.addressController,
                  decoration: const InputDecoration(labelText: "Alamat Pengiriman", border: OutlineInputBorder()),
                  maxLines: 3,
                );
              }
            }),

            const SizedBox(height: 30),
            
            // Total & Tombol
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: \$${controller.finalTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: controller.placeOrder,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  child: const Text("Place Order", style: TextStyle(color: Colors.white)),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}