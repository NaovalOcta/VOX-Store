import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:demo_modul5/app/data/models/ProductModel.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';
import 'package:demo_modul5/app/routes/app_pages.dart';

class AdminController extends GetxController {
  final SupabaseClient client = Get.find<SupabaseService>().client;

  // --- STATE ---
  var tabIndex = 0.obs;
  var products = <Product>[].obs;
  var orders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isLoadingOrders = false.obs;

  // --- INPUT CONTROLLERS (Sesuai Database) ---
  final nameController = TextEditingController(); // product_name
  final priceController = TextEditingController(); // unit_price
  final brandController = TextEditingController(); // brand
  final categoryController = TextEditingController(); // category
  final genderController = TextEditingController(); // gender
  final quantityController = TextEditingController(); // quantity
  
  // --- IMAGE STATE ---
  var selectedImage = Rxn<File>();
  var imageUrl = ''.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchOrders();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
    if (index == 0) fetchProducts();
    if (index == 2) fetchOrders();
  }

  // --- FUNGSI PICK IMAGE ---
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  // --- FUNGSI UPLOAD IMAGE KE SUPABASE STORAGE ---
  Future<String?> _uploadImageToSupabase() async {
    if (selectedImage.value == null) return null;

    try {
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';

      // Upload ke bucket 'products' (Pastikan bucket ini sudah dibuat di Supabase)
      await client.storage.from('products').upload(
        path,
        selectedImage.value!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Ambil URL Publik
      final String publicUrl = client.storage.from('products').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      Get.snackbar("Error", "Gagal upload gambar: $e", backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }

  // --- 1. PRODUK (CRUD) ---
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await client.from('products').select();
      products.value = (response as List).map((json) => Product.fromSupabase(json)).toList();
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct() async {
    // Validasi Input Sederhana
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar('Error', 'Nama dan Harga wajib diisi', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true; // Tampilkan loading saat upload

      // 1. Upload Gambar dulu (jika ada)
      String? uploadedUrl;
      if (selectedImage.value != null) {
        uploadedUrl = await _uploadImageToSupabase();
      }

      // 2. Bersihkan input harga
      String cleanPrice = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');

      // 3. Insert ke Database (Sesuai kolom di gambar database Anda)
      await client.from('products').insert({
        'product_name': nameController.text,
        'unit_price': int.tryParse(cleanPrice) ?? 0,
        'brand': brandController.text,
        'category': categoryController.text,
        'gender': genderController.text,
        'quantity': int.tryParse(quantityController.text) ?? 1,
        'image_url': uploadedUrl, // Simpan URL gambar
        'date': DateTime.now().toIso8601String(), // Isi tanggal hari ini
      });

      Get.back(); // Tutup Dialog
      fetchProducts(); // Refresh List
      
      // Reset Form
      clearControllers();
      Get.snackbar('Success', 'Produk berhasil disimpan', backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void clearControllers() {
    nameController.clear();
    priceController.clear();
    brandController.clear();
    categoryController.clear();
    genderController.clear();
    quantityController.clear();
    selectedImage.value = null;
  }

  Future<void> deleteProduct(int id) async {
    try {
      await client.from('products').delete().eq('id', id);
      fetchProducts();
      Get.snackbar('Deleted', 'Produk dihapus', backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus: $e');
    }
  }

  // --- SISA KODE (ORDER & LOGOUT) TETAP SAMA ---
  Future<void> fetchOrders() async {
    isLoadingOrders.value = true;
    try {
      final response = await client.from('orders').select('*, profiles(email), meeting_points(name)').order('created_at', ascending: false);
      orders.value = List<Map<String, dynamic>>.from(response);
    } catch (e) { print(e); } finally { isLoadingOrders.value = false; }
  }

  Future<void> updateOrderStatus(int id, String status) async {
    await client.from('orders').update({'status': status}).eq('id', id);
    fetchOrders();
  }

  Future<void> logout() async {
    await client.auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}