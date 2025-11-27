import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/modules/cart/controllers/cart_controller.dart';
import 'package:demo_modul5/app/data/models/CartItemModel.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181C24) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF2A2F36) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2329);
    const primaryBlue = Color(0xFF5B9EE1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: textColor,
                ),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          "My Cart",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. LIST ITEMS (Area Atas)
          Expanded(
            child: Obx(() {
              if (controller.cartItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Your cart is empty",
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: controller.cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItem(
                    context,
                    item,
                    isDark,
                    cardColor,
                    textColor,
                    primaryBlue,
                  );
                },
              );
            }),
          ),

          // 2. BOTTOM SUMMARY (Area Bawah - Swipeable)
          Obx(
            () => controller.cartItems.isEmpty
                ? const SizedBox()
                : Container(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 10,
                      bottom: 150,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- HANDLE TOGGLE (SWIPE AREA) ---
                        GestureDetector(
                          // 1. Tetap bisa di-tap
                          onTap: () => controller.toggleSummary(),

                          // 2. Deteksi Geser Vertikal
                          onVerticalDragEnd: (details) {
                            double velocity = details.primaryVelocity ?? 0;

                            // Jika geser ke BAWAH (Velocity Positif) -> Tutup
                            if (velocity > 0) {
                              if (controller.isSummaryExpanded.value) {
                                controller.toggleSummary();
                              }
                            }
                            // Jika geser ke ATAS (Velocity Negatif) -> Buka
                            else if (velocity < 0) {
                              if (!controller.isSummaryExpanded.value) {
                                controller.toggleSummary();
                              }
                            }
                          },
                          behavior: HitTestBehavior
                              .opaque, // Agar seluruh area container bisa disentuh
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(
                              bottom: 15,
                              top: 5,
                            ), // Area sentuh diperbesar sedikit
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),

                        // --- ANIMASI RINCIAN ---
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: controller.isSummaryExpanded.value
                              ? Column(
                                  children: [
                                    _buildSummaryRow(
                                      "Subtotal",
                                      "\$${controller.totalAmount.toStringAsFixed(2)}",
                                      textColor,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildSummaryRow(
                                      "Shopping",
                                      "\$${controller.shippingCost.toStringAsFixed(2)}",
                                      textColor,
                                    ),
                                    const SizedBox(height: 20),
                                    Divider(color: Colors.grey[300]),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // --- BAGIAN TETAP (Total & Checkout) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Cost",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "\$${controller.grandTotal.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Tombol Checkout
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.snackbar("Checkout", "Process to payment...");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              shadowColor: primaryBlue.withOpacity(0.4),
                            ),
                            child: const Text(
                              "Checkout",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color primaryBlue,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : const Color(0xFFF7F7F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Hero(
              tag: 'cart_img_${item.id}',
              child: item.image_url.isNotEmpty
                  ? Image.network(
                      item.image_url,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image, color: Colors.grey[400]),
                    )
                  : Icon(Icons.image, color: Colors.grey[400]),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.price,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _buildQtyBtn(
                      Icons.remove,
                      isDark,
                      () => controller.updateQuantity(item, -1),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${item.quantity}",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildQtyBtn(
                      Icons.add,
                      isDark,
                      () => controller.updateQuantity(item, 1),
                      isBlue: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.size,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 25),
              IconButton(
                onPressed: () => controller.deleteItem(item),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(
    IconData icon,
    bool isDark,
    VoidCallback onTap, {
    bool isBlue = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isBlue
              ? const Color(0xFF5B9EE1)
              : (isDark ? Colors.grey[800] : Colors.grey[200]),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: isBlue ? Colors.white : Colors.grey),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
