// lib/services/ThemeService.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  late SharedPreferences _prefs;
  
  // Gunakan RxBool agar UI bisa bereaksi otomatis
  final isDarkMode = false.obs; 

  // Inisialisasi SharedPreferences
  Future<ThemeService> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Muat tema yang tersimpan saat aplikasi dimulai
    isDarkMode.value = _prefs.getBool('isDarkMode') ?? false;
    return this;
  }

  // Fungsi untuk mengganti dan menyimpan tema
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    // Simpan preferensi tema ke shared_preferences
    _prefs.setBool('isDarkMode', isDarkMode.value);
    
    // Terapkan tema ke GetX
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  
  // Getter untuk tema saat ini
  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
}