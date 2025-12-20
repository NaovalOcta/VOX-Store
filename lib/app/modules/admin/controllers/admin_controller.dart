import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Sesuaikan import model ini dengan struktur project Anda
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

  // --- INPUT CONTROLLERS (FORM PRODUK) ---
  final nameController = TextEditingController();
  final priceController = TextEditingController(); // Unit Price
  final brandController = TextEditingController();
  final categoryController = TextEditingController();
  final genderController = TextEditingController();
  final quantityController = TextEditingController();

  // -- Field Baru Sesuai CSV --
  final typeController = TextEditingController(); // Product Type
  final countryController = TextEditingController(); // Country
  final descController = TextEditingController(); // Description

  // -- Input Tambahan untuk Size & Grade --
  final sizeInputController = TextEditingController();
  final gradeInputController = TextEditingController();

  // --- MULTI-VALUE STATE ---
  var selectedImages = <File>[].obs; // List untuk BANYAK gambar
  var sizeList = <String>[].obs; // List untuk BANYAK size
  var gradeList = <String>[].obs; // List untuk BANYAK grade

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

  // --- PERMISSION ---
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return await Permission.photos.request().isGranted;
      } else {
        return await Permission.storage.request().isGranted;
      }
    }
    return true; // iOS
  }

  // --- PICK MULTIPLE IMAGES ---
  Future<void> pickImages() async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      Get.snackbar(
        "Izin Ditolak",
        "Butuh akses galeri.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Pakai pickMultiImage
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      if (images != null && images.isNotEmpty) {
        selectedImages.addAll(images.map((e) => File(e.path)).toList());
      }
    } catch (e) {
      print("Error Pick Images: $e");
      Get.snackbar("Error", "Gagal mengambil gambar: $e");
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  // --- MANAGE SIZE & GRADE ---
  void addSize(String value) {
    if (value.trim().isNotEmpty) {
      sizeList.add(value.trim());
      sizeInputController.clear();
    }
  }

  void removeSize(String value) => sizeList.remove(value);

  void addGrade(String value) {
    if (value.trim().isNotEmpty) {
      gradeList.add(value.trim());
      gradeInputController.clear();
    }
  }

  void removeGrade(String value) => gradeList.remove(value);

  // --- SIMPAN PRODUK (MULTI IMAGE & ARRAY DATA) ---
  Future<void> addProduct() async {
    // Validasi Dasar
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nama dan Harga wajib diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedImages.isEmpty) {
      Get.snackbar(
        'Error',
        'Minimal pilih 1 gambar!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 1. Upload Semua Gambar Loop
      List<String> imageUrls = [];
      for (var image in selectedImages) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${selectedImages.indexOf(image)}.jpg';
        final path = 'uploads/$fileName';

        await client.storage
            .from('products')
            .upload(
              path,
              image,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        final String publicUrl = client.storage
            .from('products')
            .getPublicUrl(path);
        imageUrls.add(publicUrl);
      }

      // 2. Persiapan Data
      String cleanPrice = priceController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      int qty = int.tryParse(quantityController.text) ?? 1;
      double unitPrice = double.tryParse(cleanPrice) ?? 0;
      double amount = qty * unitPrice; // Hitung amount otomatis

      // 3. Insert ke Database (Pastikan kolom di Supabase sudah text[])
      await client.from('products').insert({
        'product_name': nameController.text,
        'product_type': typeController.text,
        'brand': brandController.text,
        'gender': genderController.text,
        'category': categoryController.text,
        'country': countryController.text,
        'quantity': qty,
        'unit_price': unitPrice,
        'amount': amount,
        'image_url': imageUrls, // Array
        'sizes': sizeList, // Array
        'grades': gradeList, // Array
        'description': descController.text,
        'created_at': DateTime.now().toIso8601String(),
        // Sesuaikan nama kolom tanggal jika beda (misal: 'date' atau 'created_at')
        'date': DateTime.now().toIso8601String(),
      });

      Get.back(); // Tutup BottomSheet
      fetchProducts();
      clearControllers();
      Get.snackbar(
        'Sukses',
        'Produk berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error Save: $e");
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

  void clearControllers() {
    nameController.clear();
    priceController.clear();
    brandController.clear();
    categoryController.clear();
    genderController.clear();
    quantityController.clear();
    typeController.clear();
    countryController.clear();
    descController.clear();
    sizeInputController.clear();
    gradeInputController.clear();

    selectedImages.clear();
    sizeList.clear();
    gradeList.clear();
  }

  // --- FETCH DATA ---
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await client
          .from('products')
          .select()
          .order('created_at', ascending: false);
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
