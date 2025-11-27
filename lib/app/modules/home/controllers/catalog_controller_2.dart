// lib/app/modules/home/controllers/catalog_controller_2.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/data/models/ProductModel.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart'; // Import service
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CatalogController extends GetxController {
  // ... (semua variabel lain tetap sama)
  String _dataSource = 'None';
  List<Product> _masterProductList = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String _statusMessage = 'Initializing...';
  String _searchQuery = '';
  bool isShoppingIconPressed = false;

  final TextEditingController searchC = TextEditingController();
  var isSearchAnimating = false.obs;
  late Box<Product> _productBox;
  final SupabaseClient _supabase = Get.find<SupabaseService>().client;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get statusMessage => _statusMessage;

  @override
  void onInit() {
    super.onInit();
    _productBox = Hive.box<Product>('productBox');
    _dataSource = 'None';
    fetchFromHive();
  }

  void toggleShoppingIcon() {
    isShoppingIconPressed = !isShoppingIconPressed;
    update();
  }

  void _setLoading(bool value, String message) {
    _isLoading = value;
    _statusMessage = message;
    update();
  }

  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
    // Opsional: Panggil fetch data khusus jika tab berubah
    // if (index == 3) fetchInbox();
  }

  Future<void> handleSearchPress() async {
    // 1. Mulai Animasi (Kecilkan tombol)
    isSearchAnimating.value = true;

    // 2. Paksa Pindah ke Tab Home (Index 0) agar hasil search terlihat
    if (tabIndex.value != 0) {
      changeTabIndex(0);
    }

    // 3. Tunggu sebentar agar animasi "tekan" terlihat (150ms)
    await Future.delayed(const Duration(milliseconds: 150));

    // 4. Kembalikan ukuran tombol (Normal)
    isSearchAnimating.value = false;
  }

  Future<void> fetchFromSupabase() async {
    try {
      _setLoading(true, 'Fetching data from Supabase...');
      final response = await _supabase.from('products').select();
      final List<dynamic> jsonList = response as List;
      _masterProductList = jsonList
          .map((json) => Product.fromSupabase(json))
          .toList();
      await _saveToHive(_masterProductList);
      _dataSource = 'Supabase Cloud';
      _applyFilter();
    } catch (e) {
      _setLoading(false, 'Error fetching (Supabase): ${e.toString()}.');
      _statusMessage = 'Supabase fetch failed. (Source: $_dataSource)';
      update();
    }
  }

  Future<void> fetchFromHive() async {
    _setLoading(true, 'Fetching data from Hive cache...');
    _masterProductList = _productBox.values.toList();
    if (_masterProductList.isNotEmpty) {
      _dataSource = 'Hive Cache';
    } else {
      _dataSource = 'None';
    }
    _applyFilter();
  }

  Future<void> _saveToHive(List<Product> products) async {
    await _productBox.clear();
    await _productBox.addAll(products);
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  // Fungsi untuk membersihkan pencarian
  void clearSearch() {
    searchC.clear();
    updateSearchQuery('');
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _products = List.from(_masterProductList);
    } else {
      final queryLower = _searchQuery.toLowerCase();
      _products = _masterProductList.where((product) {
        final nameMatch = product.name.toLowerCase().contains(queryLower);
        final priceMatch = product.price.toLowerCase().contains(queryLower);
        return nameMatch || priceMatch;
      }).toList();
    }
    _isLoading = false;
    if (_products.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        _statusMessage =
            'No products found for "$_searchQuery". (Source: $_dataSource)';
      } else {
        _statusMessage = 'No products found. (Source: $_dataSource)';
      }
    } else {
      _statusMessage =
          'Showing ${_products.length} of ${_masterProductList.length} items. (Source: $_dataSource)';
    }
    update();
  }
}
