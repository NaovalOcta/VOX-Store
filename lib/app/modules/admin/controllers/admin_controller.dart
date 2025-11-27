// lib/app/modules/admin/controllers/admin_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/data/models/FullProductModel.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';
import 'package:demo_modul5/app/modules/auth/controllers/auth_controller.dart';

class AdminController extends GetxController {
  final supabase = Get.find<SupabaseService>().client;
  final AuthController authC = Get.find(); // Untuk logout

  final products = <FullProductModel>[].obs;
  final isLoading = true.obs;

  // Controller untuk form dialog
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final categoryC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final response = await supabase
          .from('products')
          .select()
          .order('id', ascending: true);

      products.value = (response as List)
          .map((json) => FullProductModel.fromSupabase(json))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct() async {
    try {
      // Buat model baru dari data form
      final newProduct = FullProductModel(
        id: 0, // ID akan di-generate oleh Supabase
        name: nameC.text,
        unit_price: double.tryParse(priceC.text) ?? 0.0,
        category: categoryC.text,
        // Isi field lain dengan default jika perlu
        date: DateTime.now().toIso8601String(),
        product_type: 'N/A',
        brand: 'N/A',
        gender: 'N/A',
        country: 'N/A',
        quantity: 0,
        amount: 0.0,
        payment_mode: 'N/A',
      );

      await supabase.from('products').insert(newProduct.toJsonForInsert());

      Get.back(); // Tutup dialog
      fetchProducts(); // Refresh list
      Get.snackbar('Success', 'Product added!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: ${e.toString()}');
    }
  }

  Future<void> updateProduct(int id) async {
    try {
      // Buat model baru dari data form
      final updatedProductData = {
        'product_name': nameC.text,
        'unit_price': double.tryParse(priceC.text) ?? 0.0,
        'category': categoryC.text,
      };

      await supabase.from('products').update(updatedProductData).eq('id', id);

      Get.back(); // Tutup dialog
      fetchProducts(); // Refresh list
      Get.snackbar('Success', 'Product updated!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: ${e.toString()}');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await supabase.from('products').delete().eq('id', id);
      Get.back(); // Tutup dialog konfirmasi
      fetchProducts(); // Refresh list
      Get.snackbar('Success', 'Product deleted!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: ${e.toString()}');
    }
  }

  // UI untuk menampilkan dialog Tambah/Edit
  void showProductDialog({FullProductModel? product}) {
    // Jika product tidak null, kita sedang mode edit
    final isEdit = product != null;

    // Isi form dengan data yang ada jika mode edit
    nameC.text = product?.name ?? '';
    priceC.text = product?.unit_price.toString() ?? '';
    categoryC.text = product?.category ?? '';

    Get.defaultDialog(
      title: isEdit ? 'Edit Product' : 'Add Product',
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: priceC,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: categoryC,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (isEdit) {
            updateProduct(product.id);
          } else {
            addProduct();
          }
        },
        child: Text(isEdit ? 'Update' : 'Save'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}
