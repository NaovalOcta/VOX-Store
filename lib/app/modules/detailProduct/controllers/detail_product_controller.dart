import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/data/models/ProductModel.dart';
import 'package:demo_modul5/app/modules/cart/controllers/cart_controller.dart';

class DetailProductController extends GetxController {
  // Variabel Produk
  late final Product product;

  var currentImageIndex = 0.obs;
  var selectedSizeIndex = 0.obs;
  var selectedGradeIndex = 0.obs;
  var isFavorite = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Validasi Arguments agar tidak crash jika null
    if (Get.arguments is Product) {
      product = Get.arguments;
    } else {
      // Fallback dummy product jika argumen gagal (Safety net)
      product = Product(
        name: "Error Product",
        price: "0",
        images: [],
        description: "Terjadi kesalahan memuat data.",
      );
      Get.snackbar("Error", "Gagal memuat data produk");
    }
  }

  // Getter Aman untuk Images
  List<String> get productImages {
    if (product.images.isNotEmpty) return product.images;
    // Gambar default jika kosong/error
    return ['https://via.placeholder.com/400x400?text=No+Image'];
  }

  // Getter Aman untuk Size
  List<String> get availableSizes =>
      product.sizes.isNotEmpty ? product.sizes : ['All Size'];

  // Getter Aman untuk Grade
  List<String> get availableGrades =>
      product.grades.isNotEmpty ? product.grades : ['Standard'];

  void changeImageIndex(int index) => currentImageIndex.value = index;
  void selectSize(int index) => selectedSizeIndex.value = index;
  void selectGrade(int index) => selectedGradeIndex.value = index;

  void addToCart() {
    if (Get.isRegistered<CartController>()) {
      final cartC = Get.find<CartController>();

      String chosenSize = availableSizes[selectedSizeIndex.value];
      String chosenGrade = availableGrades[selectedGradeIndex.value];

      // Kirim data ke cart
      cartC.addToCart(product, chosenSize);

      Get.snackbar(
        "Berhasil",
        "${product.name}\nSize: $chosenSize | Grade: $chosenGrade",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } else {
      Get.snackbar("Error", "Controller Keranjang tidak ditemukan");
    }
  }
}
