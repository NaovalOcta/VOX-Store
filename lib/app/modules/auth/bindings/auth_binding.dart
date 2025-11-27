// lib/app/modules/auth/bindings/auth_binding.dart
import 'package:get/get.dart';
// HAPUS IMPORT SPLASH CONTROLLER
// import 'package:demo_modul5_v3/app/modules/splash/controllers/splash_controller.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    // HAPUS BARIS DI BAWAH INI. SplashController sudah ada di memori.
    // Get.lazyPut<SplashController>(
    //   () => SplashController(),
    // );
  }
}
