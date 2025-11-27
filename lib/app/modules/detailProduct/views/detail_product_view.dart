import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/modules/detailProduct/controllers/detail_product_controller.dart';
import 'package:demo_modul5/app/modules/home/controllers/catalog_controller_2.dart';

class DetailProductView extends GetView<DetailProductController> {
  const DetailProductView({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181C24) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF1E2329);
    final cardColor = isDark ? const Color(0xFF2A2F36) : Colors.white;
    const primaryBlue = Color(0xFF5B9EE1);

    return Scaffold(
      backgroundColor: bgColor,
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey[200],
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Text(
          "Men's Shoes", // Bisa diganti controller.product.category
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[200],
              child: IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: textColor,
                ),
                onPressed: () {
                  // Karena CartView ada di Tab 1 Home, kita bisa pakai ini:
                  final homeC = Get.find<CatalogController>();
                  homeC.changeTabIndex(1); // Set tab ke Cart
                  Get.back(); // Tutup halaman detail kembali ke Home(Tab Cart)

                  // ATAU jika mau navigasi stack biasa:
                  // Get.to(() => const CartView());
                },
              ),
            ),
          ),
        ],
      ),

      // --- BODY ---
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // 1. IMAGE SLIDER (Pengganti 3D)
                  _buildImageSlider(context, isDark),

                  const SizedBox(height: 30),

                  // 2. PRODUCT INFO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "BEST SELLER",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.product.name,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.product.price, // Harga Display
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Air Jordan is an American brand of basketball shoes athletic, casual, and style clothing produced by Nike. Created for Hall of Fame former NBA player Michael Jordan.", // Dummy Description
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. GALLERY (Thumbnail Kecil)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "Gallery",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGallery(isDark),

                  const SizedBox(height: 24),

                  // 4. SIZE SELECTOR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Size",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "EU",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "US",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "UK",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSizeSelector(isDark, primaryBlue, textColor),

                  const SizedBox(height: 40), // Space bawah sebelum bottom bar
                ],
              ),
            ),
          ),

          // --- BOTTOM BAR (Price & Add to Cart) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Price",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.product.price,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => controller.addToCart(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: primaryBlue.withOpacity(0.4),
                  ),
                  child: const Text(
                    "Add To Cart",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildImageSlider(BuildContext context, bool isDark) {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background Circle Decoration (Efek 3D look)
          Positioned(
            bottom: 20,
            child: Container(
              width: 300,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(300, 150),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  width: 2,
                ),
              ),
            ),
          ),

          // Image Slider
          PageView.builder(
            onPageChanged: controller.changeImageIndex,
            itemCount: 3, // Dummy 3 gambar
            itemBuilder: (context, index) {
              return Center(
                child: Hero(
                  tag:
                      'product_image_${controller.product.api_id}', // Hero animation
                  child: Icon(
                    Icons
                        .shopping_cart, // Placeholder Image (Ganti Image.network nanti)
                    size: 180,
                    color: index == 0 ? const Color(0xFF5B9EE1) : Colors.grey,
                  ),
                ),
              );
            },
          ),

          // Indicators (Dots)
          Positioned(
            bottom: 0,
            child: Obx(
              () => Row(
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: controller.currentImageIndex.value == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: controller.currentImageIndex.value == index
                          ? const Color(0xFF5B9EE1)
                          : Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(bool isDark) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Container(
            width: 70,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2F36) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.transparent,
              ), // Bisa tambah border jika selected
            ),
            child: Center(
              child: Icon(
                Icons.image,
                color: isDark ? Colors.white54 : Colors.black26,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSizeSelector(bool isDark, Color primaryColor, Color textColor) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: controller.sizes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedSizeIndex.value == index;
            return GestureDetector(
              onTap: () => controller.selectSize(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : (isDark ? const Color(0xFF2A2F36) : Colors.white),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    controller.sizes[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[500],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
