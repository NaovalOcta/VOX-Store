import 'dart:io'; // WAJIB: Untuk cek Platform
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // WAJIB: Tambahkan ini

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

  // --- FUNGSI HELPER IZIN (Letakkan di dalam Class) ---
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      // Untuk Android 13+ (API 33 ke atas) menggunakan 'photos'
      // Untuk Android 12 ke bawah menggunakan 'storage'
      
      // Cek apakah ini Android 13 atau lebih baru (SDK 33)
      // Kita coba minta izin PHOTOS dulu (untuk Android 13+)
      var statusPhotos = await Permission.photos.status;
      if (statusPhotos.isDenied || statusPhotos.isLimited) {
         // Request ulang jika belum granted
         if (await Permission.photos.request().isGranted) {
           return true;
         }
      } else if (statusPhotos.isGranted) {
        return true;
      }

      // Jika photos tidak berhasil (atau device lama), coba STORAGE
      var statusStorage = await Permission.storage.status;
      if (statusStorage.isDenied) {
        if (await Permission.storage.request().isGranted) {
          return true;
        }
      } else if (statusStorage.isGranted) {
        return true;
      }
      
      // Jika semua ditolak
      return false;
    }
    return true; // iOS biasanya otomatis handle oleh image_picker
  }

  // --- FUNGSI PICK IMAGE (UPDATE) ---
  Future<void> pickImage() async {
    // 1. Cek Izin Dulu
    bool hasPermission = await _requestPermission();
    
    if (!hasPermission) {
      Get.snackbar(
        "Izin Ditolak", 
        "Aplikasi butuh akses galeri. Mohon izinkan di Pengaturan.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        mainButton: TextButton(
          onPressed: () => openAppSettings(), // Buka setting HP
          child: const Text("Buka Setting", style: TextStyle(color: Colors.white)),
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
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal ambil gambar: $e");
    }
  }

  // --- FUNGSI UPLOAD KE SUPABASE ---
  Future<String?> _uploadImageToSupabase() async {
    if (selectedImage.value == null) return null;

    try {
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'uploads/$fileName';

      await client.storage.from('products').upload(
        path,
        selectedImage.value!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final String publicUrl = client.storage.from('products').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print("Upload Error: $e"); // Debugging
      return null;
    }
  }

  // --- CRUD FUNCTIONS (Tetap Sama) ---
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
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar('Error', 'Nama dan Harga wajib diisi', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      
      // Upload gambar dulu
      String? uploadedUrl;
      if (selectedImage.value != null) {
        uploadedUrl = await _uploadImageToSupabase();
      }

      String cleanPrice = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');

      await client.from('products').insert({
        'product_name': nameController.text,
        'unit_price': int.tryParse(cleanPrice) ?? 0,
        'brand': brandController.text,
        'category': categoryController.text,
        'gender': genderController.text,
        'quantity': int.tryParse(quantityController.text) ?? 1,
        'image_url': uploadedUrl,
        'date': DateTime.now().toIso8601String(),
      });

      Get.back();
      fetchProducts();
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