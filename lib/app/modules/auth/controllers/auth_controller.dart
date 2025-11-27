import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';
import 'package:demo_modul5/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final supabase = Get.find<SupabaseService>().client;
  late SharedPreferences _prefs;
  
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initPrefs(); 
  }

  @override
  void onReady() {
    super.onReady();
    // PERBAIKAN: Cek login hanya jika kita sedang di halaman LOGIN atau SPLASH
    // Ini mencegah loop refresh saat kita sudah berada di Home
    if (Get.currentRoute == Routes.LOGIN || Get.currentRoute == Routes.SPLASH) {
      _checkAutoLogin();
    }
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _checkAutoLogin() async {
    // Pastikan prefs sudah terinisialisasi
    if (!_prefs.containsKey('isLoggedIn')) return;

    final bool isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      final String? savedRole = _prefs.getString('userRole');
      
      // Redirect sesuai role yang tersimpan
      if (savedRole == 'admin') {
        Get.offAllNamed(Routes.ADMIN);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
    }
  }

  Future<void> register() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar('Error', 'Email and password cannot be empty');
      return;
    }
    isLoading.value = true;
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: emailC.text,
        password: passwordC.text,
      );
      
      Get.snackbar("Registration Successful", "Creating profile...");
      await Future.delayed(const Duration(seconds: 2));

      if (res.user != null) {
        await _handleAuthSuccess(res.user!);
      } else {
        isLoading.value = false;
        Get.offNamed(Routes.LOGIN);
      }
    } on AuthException catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.message);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }

  Future<void> login() async {
    if (emailC.text.isEmpty || passwordC.text.isEmpty) {
      Get.snackbar('Error', 'Email and password cannot be empty');
      return;
    }
    isLoading.value = true;
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: emailC.text,
        password: passwordC.text,
      );
      
      if (res.user != null) {
        await _handleAuthSuccess(res.user!);
      } else {
        isLoading.value = false;
        Get.snackbar('Error', 'Login failed.');
      }
    } on AuthException catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.message);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    }
  }

  Future<void> _handleAuthSuccess(User user) async {
    try {
      final data = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      
      final String role = data['role'] ?? 'user';

      // Simpan Sesi Lokal
      await _prefs.setBool('isLoggedIn', true);
      await _prefs.setString('userId', user.id);
      await _prefs.setString('userEmail', user.email ?? '');
      await _prefs.setString('userRole', role);

      isLoading.value = false;
      
      if (role == 'admin') {
        Get.offAllNamed(Routes.ADMIN);
      } else {
        Get.offAllNamed(Routes.HOME);
      }
      
      Get.snackbar("Success", "Welcome back!");

    } catch (e) {
      isLoading.value = false;
      await supabase.auth.signOut();
      Get.snackbar('Error', 'Failed to fetch user profile.');
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    
    // Hapus data sesi lokal
    await _prefs.clear(); // Menghapus semua data (login, role, theme jika disatukan)
    // Jika ThemeService menggunakan instance prefs yang berbeda/terpisah key-nya, aman.
    // Jika ingin lebih spesifik:
    // await _prefs.remove('isLoggedIn');
    // await _prefs.remove('userRole');

    Get.offAllNamed(Routes.LOGIN);
  }
}