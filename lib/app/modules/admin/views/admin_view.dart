import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/modules/admin/controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan controller ter-register
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
              _buildProductList(context), // Tab 0: Produk
              Container(), // Tab 1: Placeholder
              _buildAdminProfile(context), // Tab 2: Profile/Order
            ],
          ),
        ),
      ),
      // --- FAB TENGAH UNTUK MEMBUKA POP-UP ---
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          onPressed: () => _showAddProductDialog(context), // POP UP FUNCTION
          backgroundColor: const Color(0xFF5B9EE1),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  // --- WIDGET BOTTOM APP BAR (NAVIGASI) ---
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

  // --- TAB 1: LIST PRODUK ---
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
        if (controller.isLoading.value)
          return const Center(child: CircularProgressIndicator());
        if (controller.products.isEmpty)
          return Center(
            child: Text("Belum ada produk", style: TextStyle(color: textColor)),
          );

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];

            // Handle display image logic (ambil yg pertama jika array/list)
            // Note: Sesuaikan model Product jika image_url string atau list.
            // Anggap di list view kita tampilkan basic dulu.

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
                  child: const Icon(Icons.image, color: Colors.grey),
                  // Anda bisa update logika Image.network di sini sesuai struktur data baru
                ),
                title: Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  "Rp ${product.price}",
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

  // --- POP UP (BOTTOM SHEET) TAMBAH PRODUK ---
  // Ini yang anda minta untuk dipertahankan style-nya tapi diperlengkap isinya
  void _showAddProductDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2530) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    controller.clearControllers();

    Get.bottomSheet(
      Container(
        height:
            MediaQuery.of(context).size.height *
            0.9, // Sedikit lebih tinggi untuk muat konten
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
            // Header Pop Up
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

            // Content Form Scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. MULTI IMAGE PICKER ---
                    const Text(
                      "Foto Produk (Multi)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Obx(() {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: controller.pickImages,
                            child: Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: controller.selectedImages.isEmpty
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 40,
                                          color: Colors.grey[600],
                                        ),
                                        Text(
                                          "Tap untuk pilih banyak foto",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.all(8),
                                      itemCount:
                                          controller.selectedImages.length,
                                      itemBuilder: (context, index) {
                                        return Stack(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              width: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: FileImage(
                                                    controller
                                                        .selectedImages[index],
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: GestureDetector(
                                                onTap: () => controller
                                                    .removeImage(index),
                                                child: const CircleAvatar(
                                                  backgroundColor: Colors.red,
                                                  radius: 10,
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                          ),
                          if (controller.selectedImages.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                "${controller.selectedImages.length} gambar dipilih",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),

                    // --- 2. TEXT FIELDS (SESUAI CSV) ---
                    _buildTextField(
                      "Nama Produk",
                      controller.nameController,
                      textColor,
                      isDark,
                    ),
                    _buildTextField(
                      "Harga Satuan (Rp)",
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
                            "Type",
                            controller.typeController,
                            textColor,
                            isDark,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Category",
                            controller.categoryController,
                            textColor,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Gender",
                            controller.genderController,
                            textColor,
                            isDark,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Country",
                            controller.countryController,
                            textColor,
                            isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Quantity",
                            controller.quantityController,
                            textColor,
                            isDark,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),

                    // --- 3. SIZE & GRADE (DYNAMIC INPUT) ---
                    const SizedBox(height: 10),
                    Text(
                      "Available Sizes",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Input Size (e.g. 42)",
                            controller.sizeInputController,
                            textColor,
                            isDark,
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.addSize(
                            controller.sizeInputController.text,
                          ),
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        children: controller.sizeList
                            .map(
                              (e) => Chip(
                                label: Text(e),
                                onDeleted: () => controller.removeSize(e),
                                deleteIcon: const Icon(Icons.close, size: 16),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "Condition Grades",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Input Grade (e.g. A)",
                            controller.gradeInputController,
                            textColor,
                            isDark,
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.addGrade(
                            controller.gradeInputController.text,
                          ),
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        children: controller.gradeList
                            .map(
                              (e) => Chip(
                                label: Text(e),
                                backgroundColor: Colors.amber[100],
                                onDeleted: () => controller.removeGrade(e),
                                deleteIcon: const Icon(Icons.close, size: 16),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 10),
                    _buildTextField(
                      "Description",
                      controller.descController,
                      textColor,
                      isDark,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- 4. TOMBOL SIMPAN ---
            const SizedBox(height: 10),
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
      isScrollControlled: true,
    );
  }

  // --- COMPONENT TEXT FIELD ---
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

  // --- TAB 2: PROFILE & ORDERS (TIDAK BERUBAH DARI KODE ASLI ANDA) ---
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
              if (controller.isLoadingOrders.value)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              if (controller.orders.isEmpty)
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Belum ada pesanan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
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
                          order['profiles']?['email'] ?? 'User',
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
