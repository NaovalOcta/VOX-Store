import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // WAJIB IMPORT INI
import 'package:get/get.dart';
import 'package:demo_modul5/app/modules/admin/controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdminController>()) {
      Get.put(AdminController());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181C24) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        child: Obx(
          () => IndexedStack(
            index: controller.tabIndex.value,
            children: [
              _buildProductList(context),
              Container(),
              _buildAdminProfile(context),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          onPressed: () => _showAddProductDialog(context),
          backgroundColor: const Color(0xFF5B9EE1),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF1F2530) : Colors.white;
    const activeColor = Color(0xFF5B9EE1);

    return BottomAppBar(
      color: barColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      clipBehavior: Clip.antiAlias,
      height: 70,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => controller.changeTabIndex(0),
              icon: Icon(
                Icons.dashboard_rounded,
                color: controller.tabIndex.value == 0
                    ? activeColor
                    : Colors.grey,
                size: 28,
              ),
              tooltip: "Products",
            ),
            const SizedBox(width: 40),
            IconButton(
              onPressed: () => controller.changeTabIndex(2),
              icon: Icon(
                Icons.person_rounded,
                color: controller.tabIndex.value == 2
                    ? activeColor
                    : Colors.grey,
                size: 28,
              ),
              tooltip: "Orders",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Kelola Produk',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: controller.fetchProducts,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.products.isEmpty) {
          return Center(
            child: Text("Belum ada produk", style: TextStyle(color: textColor)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return Card(
              color: isDark ? const Color(0xFF2A2F36) : Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: product.image_url != null
                      ? Image.network(
                          product.image_url!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
                title: Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  product.price,
                  style: const TextStyle(
                    color: Color(0xFF5B9EE1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _confirmDelete(context, product.api_id ?? 0),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // --- DIALOG TAMBAH PRODUK YANG DIPERBARUI ---
  void _showAddProductDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2530) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    // Pastikan reset controller agar form kosong
    controller.clearControllers();

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85, // Tinggi 85% layar
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tambah Produk Baru",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: textColor),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- 1. IMAGE PICKER ---
                    GestureDetector(
                      onTap: controller.pickImage,
                      child: Obx(
                        () => Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                            image: controller.selectedImage.value != null
                                ? DecorationImage(
                                    image: FileImage(
                                      controller.selectedImage.value!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: controller.selectedImage.value == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Upload Foto Produk",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- 2. INPUT FIELDS ---
                    _buildTextField(
                      "Nama Produk",
                      controller.nameController,
                      textColor,
                      isDark,
                    ),
                    _buildTextField(
                      "Harga (Rp)",
                      controller.priceController,
                      textColor,
                      isDark,
                      isNumber: true,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Brand",
                            controller.brandController,
                            textColor,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Stok",
                            controller.quantityController,
                            textColor,
                            isDark,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Kategori (Shoes/Acc)",
                            controller.categoryController,
                            textColor,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Gender (Men/Women)",
                            controller.genderController,
                            textColor,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- 3. SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9EE1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Simpan Produk",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true, // Agar bisa full screen (bottom sheet tinggi)
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    Color textColor,
    bool isDark, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500]),
          filled: true,
          fillColor: isDark ? Colors.black26 : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // --- HALAMAN 2: PROFILE & ORDERS ---
  Widget _buildAdminProfile(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2329);
    final cardColor = isDark ? const Color(0xFF2A2F36) : Colors.white;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF5B9EE1),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Administrator",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "admin@voxstore.com",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pesanan Masuk",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: controller.fetchOrders,
                  icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Obx(() {
              if (controller.isLoadingOrders.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (controller.orders.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Belum ada pesanan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  final isCOD = order['delivery_method'] == 'cod';
                  final status = order['status'] ?? 'Pending';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order #${order['id']}",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _statusBadge(status),
                          ],
                        ),
                        const Divider(height: 20),

                        _infoRow(
                          Icons.person,
                          order['profiles']?['email'] ?? 'User tidak dikenal',
                          textColor,
                        ),
                        const SizedBox(height: 6),
                        _infoRow(
                          isCOD ? Icons.handshake : Icons.local_shipping,
                          isCOD
                              ? "COD: ${order['meeting_points']?['name'] ?? '-'}"
                              : "Kirim: ${order['shipping_address'] ?? '-'}",
                          textColor,
                        ),
                        const SizedBox(height: 6),
                        _infoRow(
                          Icons.payments,
                          "Total: \$${order['total_amount']}",
                          const Color(0xFF5B9EE1),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (status == 'Pending')
                              ElevatedButton(
                                onPressed: () => controller.updateOrderStatus(
                                  order['id'],
                                  'Process',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                child: const Text("Proses"),
                              ),
                            const SizedBox(width: 8),
                            if (status == 'Process')
                              ElevatedButton(
                                onPressed: () => controller.updateOrderStatus(
                                  order['id'],
                                  'Done',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                child: const Text("Selesai"),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.all(16),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'Process') color = Colors.blue;
    if (status == 'Done') color = Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 14)),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    Get.defaultDialog(
      title: "Hapus Produk",
      middleText: "Yakin ingin menghapus?",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteProduct(id);
      },
    );
  }
}
