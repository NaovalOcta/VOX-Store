import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo_modul5/app/data/models/CartItemModel.dart';
import 'package:demo_modul5/app/data/models/ProductModel.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';

class CartController extends GetxController {
  final SupabaseClient supabase = Get.find<SupabaseService>().client;
  late Box<CartItem> cartBox;

  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;

  // Getter Total Harga
  double get totalAmount =>
      cartItems.fold(0, (sum, item) => sum + (item.priceValue * item.quantity));
  // Biaya pengiriman dummy
  double get shippingCost => cartItems.isEmpty ? 0.0 : 40.90;
  double get grandTotal => totalAmount + shippingCost;

  @override
  void onInit() {
    super.onInit();
    cartBox = Hive.box<CartItem>('cartBox');
    loadCart();
  }

  var isSummaryExpanded = true.obs;
  void toggleSummary() {
    isSummaryExpanded.value = !isSummaryExpanded.value;
  }

  // --- LOGIC UTAMA: FETCH CART ---
  Future<void> loadCart() async {
    // 1. Load dari Hive dulu (agar cepat)
    cartItems.assignAll(cartBox.values.toList());

    // 2. Fetch update dari Supabase
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;
      if (user != null) {
        // Query Join: Ambil cart beserta detail product-nya
        final response = await supabase
            .from('cart')
            .select('*, products(*)')
            .eq('user_id', user.id)
            .order('created_at');

        final List<dynamic> data = response;
        final serverItems = data
            .map((json) => CartItem.fromSupabase(json))
            .toList();

        // 3. Sinkronisasi Hive (Timpa data lama)
        await cartBox.clear();
        await cartBox.addAll(serverItems);

        // 4. Update UI
        cartItems.assignAll(serverItems);
      }
    } catch (e) {
      print("Error loading cart: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- ADD TO CART (Dipanggil dari Detail Page) ---
  Future<void> addToCart(Product product, String size) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Please login first");
      return;
    }

    try {
      // 1. Insert ke Supabase
      await supabase.from('cart').insert({
        'user_id': user.id,
        'product_id': product
            .api_id, // Pastikan api_id sesuai dengan id di tabel products
        'quantity': 1,
        'size': size,
      });

      // 2. Refresh Local Data
      await loadCart();

      Get.snackbar(
        "Success",
        "Added to cart successfully",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF5B9EE1), // Biru
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to add to cart: $e");
    }
  }

  // --- UPDATE QUANTITY ---
  Future<void> updateQuantity(CartItem item, int change) async {
    final newQty = item.quantity + change;
    if (newQty < 1) return;

    // Optimistic Update (Update UI duluan biar cepat)
    item.quantity = newQty;
    item.save(); // Save ke Hive
    cartItems.refresh();

    // Update Supabase di background
    if (item.id != null) {
      await supabase
          .from('cart')
          .update({'quantity': newQty})
          .eq('id', item.id!);
    }
  }

  // --- DELETE ITEM ---
  Future<void> deleteItem(CartItem item) async {
    // Hapus dari Hive
    await item.delete();
    cartItems.remove(item);

    // Hapus dari Supabase
    if (item.id != null) {
      await supabase.from('cart').delete().eq('id', item.id!);
    }
  }

  // --- CLEAR CART ---
  Future<void> clearCart() async {
    try {
      final user = supabase.auth.currentUser;

      // 1. Hapus semua data di tabel 'cart' Supabase milik user ini
      if (user != null) {
        await supabase.from('cart').delete().eq('user_id', user.id);
      }

      // 2. Hapus data lokal (Hive & Observable)
      await cartBox.clear();
      cartItems.clear();

      print("Cart cleared successfully.");
    } catch (e) {
      print("Error clearing cart: $e");
      // Jangan throw error agar flow checkout tidak terganggu hanya karena gagal clear cache
    }
  }
}
