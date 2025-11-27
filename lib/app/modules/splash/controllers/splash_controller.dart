// lib/app/modules/splash/controllers/splash_controller.dart
import 'package:get/get.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';
import 'package:demo_modul5/app/routes/app_pages.dart';

class SplashController extends GetxController {
  final supabase = Get.find<SupabaseService>().client;

  @override
  void onReady() {
    super.onReady();
    checkAuth(); // <-- Ganti nama panggilannya di sini
  }

  // --- UBAH NAMA METHOD INI (HAPUS UNDERSCORE) ---
  Future<void> checkAuth() async {
    // Tunggu sebentar untuk splash screen
    await Future.delayed(const Duration(seconds: 1));

    final user = supabase.auth.currentUser;

    if (user == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      // Jika user ada, cek rolenya
      try {
        final data = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();

        final role = data['role'];

        if (role == 'admin') {
          Get.offAllNamed(Routes.ADMIN);
        } else {
          Get.offAllNamed(Routes.HOME);
        }
      } catch (e) {
        // Jika gagal ambil role, logout saja
        supabase.auth.signOut();
        Get.offAllNamed(Routes.LOGIN);
      }
    }
  }
}
