import 'dart:io'; // WAJIB: Untuk cek Platform.isAndroid
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // WAJIB: Import ini

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

  // --- INPUT CONTROLLERS ---
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final brandController = TextEditingController();
  final categoryController = TextEditingController();
  final genderController = TextEditingController();
  final quantityController = TextEditingController();

  // --- IMAGE STATE ---
  var selectedImage = Rxn<File>();
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

  // --- FUNGSI HELPER: REQUEST PERMISSION (DIPERBAIKI) ---
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33 ke atas) wajib menggunakan Permission.photos
      // Android 12 ke bawah wajib menggunakan Permission.storage

      // KITA GUNAKAN METODE "TRY & FALLBACK"
      // 1. Cek apakah ini Android 13+ dengan meminta izin Photos
      if (await Permission.photos.request().isGranted) {
        return true;
      }

      // 2. Jika photos ditolak (atau ini Android 12-), coba minta izin Storage
      if (await Permission.storage.request().isGranted) {
        return true;
      }

      // Jika keduanya ditolak/gagal
      return false;
    }
    // iOS biasanya otomatis ditangani oleh Info.plist, tapi kita return true agar lanjut
    return true;
  }

  // --- FUNGSI PICK IMAGE ---
  Future<void> pickImage() async {
    // 1. Cek Permission
    final hasPermission = await _requestPermission();

    if (!hasPermission) {
      Get.snackbar(
        "Izin Ditolak",
        "Aplikasi membutuhkan akses galeri. Mohon izinkan di Pengaturan.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        mainButton: TextButton(
          onPressed: () => openAppSettings(), // Membuka setting HP
          child: const Text(
            "Buka Setting",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    // 2. Buka Galeri
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres sedikit
      );

      if (image != null) {
        selectedImage.value = File(image.path);
        Get.snackbar(
          "Sukses",
          "Gambar berhasil dipilih",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      print("Error Pick Image: $e");
      Get.snackbar("Error", "Gagal mengambil gambar: $e");
    }
  }

  // --- FUNGSI UPLOAD KE SUPABASE ---
  Future<String?> _uploadImageToSupabase() async {
    if (selectedImage.value == null) return null;

    try {
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';

      // Upload file
      await client.storage
          .from('products')
          .upload(
            path,
            selectedImage.value!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Ambil URL Publik
      final String publicUrl = client.storage
          .from('products')
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print("Upload Error: $e");
      Get.snackbar(
        "Gagal Upload",
        "Error: $e. Pastikan Bucket Public & Policy Insert aktif.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // Lempar error agar proses simpan data berhenti
      throw Exception("Gagal upload gambar");
    }
  }

  // --- FUNGSI SIMPAN PRODUK ---
  Future<void> addProduct() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama dan Harga wajib diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 1. Upload Gambar (jika ada)
      String? uploadedUrl;
      if (selectedImage.value != null) {
        uploadedUrl = await _uploadImageToSupabase();
      }

      // 2. Simpan ke Database
      String cleanPrice = priceController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      await client.from('products').insert({
        'product_name': nameController.text,
        'unit_price': int.tryParse(cleanPrice) ?? 0,
        'brand': brandController.text,
        'category': categoryController.text,
        'gender': genderController.text,
        'quantity': int.tryParse(quantityController.text) ?? 1,
        'image_url': uploadedUrl, // Masukkan URL gambar
        'date': DateTime.now().toIso8601String(),
      });

      Get.back();
      fetchProducts();
      clearControllers();
      Get.snackbar(
        'Success',
        'Produk berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Error akan tertangkap di sini (baik dari upload maupun insert db)
      Get.snackbar(
        'Gagal Simpan',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- CRUD Functions Lainnya ---
  void clearControllers() {
    nameController.clear();
    priceController.clear();
    brandController.clear();
    categoryController.clear();
    genderController.clear();
    quantityController.clear();
    selectedImage.value = null;
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await client.from('products').select();
      products.value = (response as List)
          .map((json) => Product.fromSupabase(json))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await client.from('products').delete().eq('id', id);
      fetchProducts();
      Get.snackbar(
        'Deleted',
        'Produk dihapus',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus: $e');
    }
  }

  Future<void> fetchOrders() async {
    isLoadingOrders.value = true;
    try {
      final response = await client
          .from('orders')
          .select('*, profiles(email), meeting_points(name)')
          .order('created_at', ascending: false);
      orders.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print(e);
    } finally {
      isLoadingOrders.value = false;
    }
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
