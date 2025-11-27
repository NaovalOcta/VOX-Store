import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/data/models/FullProductModel.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema (Dark/Light)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? const Color(0xFF1E2329)
        : const Color(0xFFF7F7F9);
    final Color cardColor = isDark ? const Color(0xFF2A2F36) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E2329);
    final Color primaryBlue = const Color(0xFF5B9EE1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: primaryBlue.withOpacity(0.1),
              child: IconButton(
                icon: Icon(Icons.logout_rounded, color: primaryBlue),
                onPressed: () => controller.authC.logout(),
                tooltip: "Logout",
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: primaryBlue));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Stats (Ringkasan Sederhana)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Products",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${controller.products.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Placeholder untuk stat lain (misal: user aktif)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Active",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: Text(
                "Manage Inventory",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            // 2. Product List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return _buildProductCard(
                    context,
                    product,
                    cardColor,
                    textColor,
                    primaryBlue,
                  );
                },
              ),
            ),
          ],
        );
      }),

      // 3. Floating Action Button (Add Product)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.showProductDialog();
        },
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add New",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
    );
  }

  // Widget Helper untuk Kartu Produk
  Widget _buildProductCard(
    BuildContext context,
    FullProductModel product,
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          // Icon Placeholder (Kotak kiri)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category.isNotEmpty
                            ? product.category
                            : "General",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product.unit_price.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons (Edit & Delete)
          Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: textColor.withOpacity(0.6),
                  size: 20,
                ),
                onPressed: () => controller.showProductDialog(product: product),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                splashRadius: 20,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Delete Product',
                    titleStyle: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: cardColor,
                    contentPadding: const EdgeInsets.all(20),
                    middleText:
                        'Are you sure you want to delete "${product.name}"?',
                    middleTextStyle: TextStyle(color: Colors.grey[600]),
                    confirm: ElevatedButton(
                      onPressed: () {
                        controller.deleteProduct(product.id);
                        Get.back(); // Tutup dialog manual karena controller refresh list
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    cancel: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  );
                },
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
