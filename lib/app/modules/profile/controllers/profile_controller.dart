import 'package:get/get.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';
import 'package:demo_modul5/app/modules/auth/controllers/auth_controller.dart';
import 'package:demo_modul5/app/data/services/ThemeService.dart';

class ProfileController extends GetxController {
  final supabase = Get.find<SupabaseService>().client;
  final authC = Get.find<AuthController>(); // Untuk Logout
  final themeService = Get.find<ThemeService>(); // Untuk Toggle Tema

  var name = 'Loading...'.obs;
  var email = 'Loading...'.obs;
  var avatarUrl = ''.obs; // Nanti bisa diisi URL gambar jika ada

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      email.value = user.email ?? 'No Email';

      try {
        // Coba ambil data tambahan dari tabel 'profiles'
        // Pastikan tabel profiles Anda memiliki kolom 'full_name' atau 'username'
        // Jika tidak ada, kode ini akan skip ke catch dan pakai email sebagai nama
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        // Sesuaikan key ini dengan nama kolom di database Supabase Anda
        // Misalnya: 'username', 'full_name', atau 'name'
        name.value = data['username'] ?? data['full_name'] ?? 'User VOX';
      } catch (e) {
        // Jika gagal ambil profile (atau belum dibuat), gunakan nama dari email
        name.value = user.email?.split('@')[0] ?? 'User';
      }
    }
  }

  void logout() {
    authC.logout();
  }
}
