import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/modules/home/controllers/catalog_controller_2.dart';
import 'package:demo_modul5/app/modules/home/views/widgets/catalog_grid_widget_2.dart';
import 'package:demo_modul5/app/modules/profile/views/profile_view.dart';
import 'package:demo_modul5/app/modules/cart/views/cart_view.dart';

class CatalogPage1 extends GetView<CatalogController> {
  const CatalogPage1({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181C24) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,

      // Body menggunakan Obx agar halaman berubah saat tabIndex berubah
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            // Index 0: HOME
            _buildHomeView(context),

            // Index 1: CART
            const CartView(),

            // Index 2: DUMMY (Untuk Search / FAB)
            // Kita gunakan container kosong karena Search muncul sbg Pop-up
            Container(),

            // Index 3: INBOX
            _buildPlaceholderView("Inbox Messages", Icons.mail_outline),

            // Index 4: PROFILE
            const ProfileView(),
          ],
        ),
      ),

      // --- TOMBOL SEARCH (FAB) DENGAN ANIMASI ---
      floatingActionButton: Obx(
        () => AnimatedScale(
          scale: controller.isSearchAnimating.value ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: SizedBox(
            height: 60,
            width: 60,
            child: FloatingActionButton(
              onPressed: () async {
                await controller.handleSearchPress();
                if (context.mounted) {
                  _showSearchDialog(context);
                }
              },
              backgroundColor: const Color(0xFF5B9EE1),
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.search, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- NAVIGATION BAR ---
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  // --- PERBAIKAN DI SINI: MENAMBAHKAN Obx() ---
  Widget _buildBottomAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF1F2530) : Colors.white;
    final activeColor = const Color(0xFF5B9EE1);
    final inactiveColor = Colors.grey.withOpacity(0.6);

    return BottomAppBar(
      color: barColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      height: 70,
      padding: EdgeInsets.zero,

      // KUNCI PERBAIKAN: Bungkus Row dengan Obx agar UI di-rebuild saat tabIndex berubah
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. HOME (Index 0)
            _buildTabItem(
              index: 0,
              icon: Icons.home_rounded,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            const SizedBox(width: 30),

            // 2. CART (Index 1)
            _buildTabItem(
              index: 1,
              icon: Icons.shopping_cart_outlined,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            // Jarak Tengah untuk FAB
            const SizedBox(width: 140),

            // 3. INBOX (Index 3)
            _buildTabItem(
              index: 3,
              icon: Icons.mail_outline_rounded,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            const SizedBox(width: 30),

            // 4. PROFILE (Index 4)
            _buildTabItem(
              index: 4,
              icon: Icons.person_outline_rounded,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    // Cek apakah tab ini yang sedang aktif
    final isSelected = controller.tabIndex.value == index;

    return IconButton(
      onPressed: () => controller.changeTabIndex(index),
      icon: Icon(
        icon,
        // Jika aktif pakai activeColor, jika tidak pakai inactiveColor
        color: isSelected ? activeColor : inactiveColor,
        size: 26,
      ),
      splashRadius: 24,
      tooltip: 'Tab $index', // Optional: Tooltip aksesibilitas
    );
  }

  // --- Dialog Search (Sama seperti sebelumnya) ---
  void _showSearchDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2F36) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2329);

    Get.dialog(
      Material(
        color: Colors.transparent,
        child: Column(
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[400]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.searchC,
                        autofocus: true,
                        style: TextStyle(color: textColor, fontSize: 16),
                        onChanged: (val) => controller.updateSearchQuery(val),
                        decoration: InputDecoration(
                          hintText: "Search product...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        controller.clearSearch();
                        Get.back();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  // --- Placeholder View ---
  Widget _buildPlaceholderView(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  // --- Home View (Sama seperti sebelumnya) ---
  Widget _buildHomeView(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1E2329);

    int getGridColumnCount(double screenWidth) {
      if (screenWidth < 600) {
        return 2;
      } else if (screenWidth < 900)
        return 3;
      else
        return 4;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey[200],
            child: IconButton(
              icon: const Icon(Icons.grid_view, size: 20),
              color: textColor,
              onPressed: () {},
            ),
          ),
        ),
        title: Text(
          'VOX Store',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final columnCount = getGridColumnCount(screenWidth);

          return Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GetBuilder<CatalogController>(
                  builder: (ctrl) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctrl.statusMessage,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: ctrl.isLoading
                                ? null
                                : ctrl.fetchFromSupabase,
                            icon: const Icon(
                              Icons.cloud_download_outlined,
                              size: 16,
                            ),
                            label: const Text("Refresh"),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF5B9EE1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton.icon(
                            onPressed: ctrl.isLoading
                                ? null
                                : ctrl.fetchFromHive,
                            icon: const Icon(Icons.save_as_outlined, size: 16),
                            label: const Text("Load Cache"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GetBuilder<CatalogController>(
                  builder: (ctrl) {
                    if (ctrl.isLoading && ctrl.products.isEmpty) {
                      return const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF5B9EE1),
                          ),
                        ),
                      );
                    }
                    final products = ctrl.products;
                    if (products.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            'No products found.',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      );
                    }
                    return Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columnCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.70,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) =>
                            CatalogGridWidget(product: products[index]),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
