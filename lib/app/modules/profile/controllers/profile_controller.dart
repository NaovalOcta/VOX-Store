import 'package:get/get.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';
import 'package:demo_modul5/app/modules/auth/controllers/auth_controller.dart';
import 'package:demo_modul5/app/data/services/ThemeService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ProfileController extends GetxController {
  final supabase = Get.find<SupabaseService>().client;
  final authC = Get.find<AuthController>(); // Untuk Logout
  final themeService = Get.find<ThemeService>(); // Untuk Toggle Tema

  var name = 'Loading...'.obs;
  var email = 'Loading...'.obs;
  var avatarUrl = ''.obs; // Nanti bisa diisi URL gambar jika ada
  var isNotificationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    loadNotificationPreference();
  }

  Future<void> loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    isNotificationEnabled.value = prefs.getBool('is_notif_enabled') ?? true;
  }

  Future<void> toggleNotification(bool value) async {
    // 1. Ubah UI secara INSTAN agar terasa responsif
    isNotificationEnabled.value = value;
    
    // 2. Simpan preferensi ke local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_notif_enabled', value);

    // 3. Handle Logika Firebase di background (tanpa memblokir UI)
    try {
      if (value) {
        // JIKA ON: Request Token baru
        print("Mengaktifkan Notifikasi...");
        String? token = await FirebaseMessaging.instance.getToken();
        print("FCM Token Baru: $token"); // Gunakan token ini untuk tes kirim notif
      } else {
        // JIKA OFF: Hapus Token
        print("Menonaktifkan Notifikasi...");
        await FirebaseMessaging.instance.deleteToken();
        print("FCM Token dihapus (Notifikasi tidak akan masuk).");
      }
    } catch (e) {
      print("Gagal mengubah status notifikasi di server: $e");
      // Opsional: Kembalikan status UI jika error fatal (biasanya tidak perlu untuk UX yang mulus)
    }
  }

  Future<void> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      email.value = user.email ?? 'No Email';
      try {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        name.value = data['username'] ?? data['full_name'] ?? 'User VOX';
      } catch (e) {
        name.value = user.email?.split('@')[0] ?? 'User';
      }
    }
  }

  void logout() {
    authC.logout();
  }
}
