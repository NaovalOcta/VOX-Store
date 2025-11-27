import 'package:flutter/material.dart'; // <--- INI PENTING: Wajib ada untuk akses Color & EdgeInsets
import 'package:get/get.dart';
import 'package:demo_modul5/app/data/models/ProductModel.dart';
import 'package:demo_modul5/app/modules/cart/controllers/cart_controller.dart';

class DetailProductController extends GetxController {
  // Menerima data produk dari halaman sebelumnya
  final Product product = Get.arguments;

  // State untuk Carousel Gambar
  var currentImageIndex = 0.obs;

  // State untuk Pilihan Size
  var selectedSizeIndex = 2.obs; // Default ke index 2 (misal size 40)
  final List<String> sizes = ['38', '39', '40', '41', '42', '43'];

  // State untuk Animasi Favorit
  var isFavorite = false.obs;

  final CartController cartC = Get.find<CartController>();

  void changeImageIndex(int index) {
    currentImageIndex.value = index;
  }

  void selectSize(int index) {
    selectedSizeIndex.value = index;
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void addToCart() {
    Get.snackbar(
      "Success",
      "${product.name} (Size ${sizes[selectedSizeIndex.value]}) added to cart",
      snackPosition: SnackPosition.TOP,
      // Karena sudah import material, kita bisa pakai Color() langsung
      backgroundColor: const Color(0xFF5B9EE1),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 20,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
    cartC.addToCart(product, sizes[selectedSizeIndex.value]);
  }
}
